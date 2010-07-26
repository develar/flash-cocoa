package org.flyti.assetBuilder;

import com.sun.istack.internal.Nullable;
import org.apache.maven.artifact.Artifact;
import org.apache.maven.model.Resource;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.project.MavenProject;
import org.codehaus.plexus.util.IOUtil;
import org.simpleframework.xml.Serializer;
import org.simpleframework.xml.core.Persister;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.*;

/**
 * @goal generate
 * @phase generate-sources
 * @requiresDependencyResolution compile
 *
 * При поиске мы формируем имя согласно key + "." + имя состояния. пока что считаем что список состояний равен "off, on".
 */
public class AssetBuilderMojo extends AbstractMojo
{
	private static final String[] DEFAULT_STATES = {"off", "on"};

	/**
     * @parameter expression="${asset.builder..skip}"
     */
    private boolean skip;

	/**
     * @parameter expression="${project}"
     * @required
     * @readonly
     */
	private MavenProject project;

	/**
     * @parameter default-value="${project.build.directory}/assets"
     */
    private File output;

//	/**
//     * @parameter
//     */
//	private File[] imageDirectories;

	/**
     * @parameter default-value="src/main/resources/assets.xml"
     */
	private File descriptor;

	private List<File> sources;

	private DataOutputStream out = null;

	@Override
	public void execute() throws MojoExecutionException, MojoFailureException
	{
		if (skip)
		{
			getLog().warn("Skipping generate assets");
			return;
		}

		if (!descriptor.exists())
		{
			getLog().warn("");
			return;
		}

		try
		{
			setUpImageDirectories();
		}
		catch (Exception e)
		{
			throw new MojoExecutionException("Can't set up images source directories", e);
		}

		Serializer serializer = new Persister();
		AssetSet assetSet;
		try
		{
			assetSet = serializer.read(AssetSet.class, descriptor);
		}
		catch (Exception e)
		{
			throw new MojoExecutionException("Can't parse descriptor", e);
		}

		try
		{
			out = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(output)));
			buildBorders(assetSet.borders);
			out.flush();
		}
		catch (IOException e)
		{
			throw new MojoExecutionException("Can't write to output file", e);
		}
		finally
		{
			IOUtil.close(out);
		}
	}

	private void setUpImageDirectories() throws IOException, ClassNotFoundException
	{
		sources = new ArrayList<File>();
		//noinspection unchecked
		for (Resource resource : (List<Resource>) project.getResources())
		{
			sources.add(new File(resource.getDirectory()));
		}

		final Map<String, String> projectResourceDirectoryMap;
		final File projectResourceDirectoryCache = new File(project.getBuild().getDirectory(), "projectResourceDirectoryMap");
		if (projectResourceDirectoryCache.exists())
		{
			//noinspection unchecked
			projectResourceDirectoryMap = (Map<String, String>) new ObjectInputStream(new FileInputStream(projectResourceDirectoryCache)).readObject();
		}
		else
		{
			projectResourceDirectoryMap = new HashMap<String, String>();
		}

		@SuppressWarnings({"unchecked"})
		Map<String, MavenProject> projectReferences = (Map<String, MavenProject>) project.getProjectReferences();
		//noinspection unchecked
		for (Artifact artifact : (Set<Artifact>) project.getArtifacts())
		{
			// пока что только берем из resource directories, но swc не парсим
			if ("swc".equals(artifact.getType()))
			{
				final String referenceProjectId = MavenProject.getProjectReferenceId(artifact.getGroupId(), artifact.getArtifactId(), artifact.getVersion());
				final File referenceResourceDirectory;
				if (projectResourceDirectoryMap.containsKey(referenceProjectId))
				{
					referenceResourceDirectory = new File(projectResourceDirectoryMap.get(referenceProjectId));
					if (!referenceResourceDirectory.exists())
					{
						projectResourceDirectoryMap.remove(referenceProjectId);
						continue;
					}
				}
				else
				{
					MavenProject referenceProject = projectReferences.get(referenceProjectId);
					referenceResourceDirectory = new File(((Resource) referenceProject.getResources().get(0)).getDirectory());
					if (referenceResourceDirectory.exists())
					{
						projectResourceDirectoryMap.put(referenceProjectId, referenceResourceDirectory.getAbsolutePath());
					}
					else
					{
						continue;
					}
				}

				sources.add(referenceResourceDirectory);
			}
		}

		if (projectResourceDirectoryMap.size() > 0)
		{
			new ObjectOutputStream(new FileOutputStream(projectResourceDirectoryCache)).writeObject(projectResourceDirectoryMap);
		}
	}

	private void buildBorders(List<Border> borders) throws IOException, MojoExecutionException
	{
		out.writeByte(borders.size());

		SliceCalculator sliceCalculator = new SliceCalculator();

		for (Border border : borders)
		{
			BorderType borderType = BorderType.valueOf(border.type);

			final String key = border.subkey == null ? border.key : (border.subkey + "." + border.key);
			out.writeUTF(key);
			out.writeByte(borderType.ordinal());

			BufferedImage[] sourceImages = getImages(key, borderType == BorderType.OneBitmap ? null : DEFAULT_STATES);

			switch (borderType)
			{
				case Scale3EdgeHBitmap:
				{
					buildMultipleBorder(sourceImages, sliceCalculator);
				}
				break;

				case OneBitmap:
				{
					writeImage(sourceImages[0]);
				}
				break;
			}

			lazyWriteInsets(border.contentInsets, true);
			lazyWriteInsets(border.frameInsets, false);
		}
	}

	private void buildMultipleBorder(BufferedImage[] sourceImages, SliceCalculator sliceCalculator) throws MojoExecutionException, IOException
	{
		// мы рассчитываем slice size для изображения on, а не off состояния, так как зачастую именно оно дает наиболее полный slice size,
		// иначе для off оно будет маленьким и его не хватит для on (на примере Fluent PopUp Button в on будет обрезана стрелка) — мы то считаем один раз для всех состояний.
		// Такая политика — расчет по одному изображения для всех состояний на 100% работает для Aqua UI, а во Fluent UI есть вот такие заморочки.
		Insets sliceSize = sliceCalculator.calculate(sourceImages[1], false, false);
		BufferedImage[] finalImages = slice3H(sourceImages, sliceSize);

		out.writeByte(finalImages.length);

		for (BufferedImage image : finalImages)
		{
			writeImage(image);
		}
	}

	private void writeImage(BufferedImage image) throws IOException
	{
		out.writeByte(image.getWidth());
		out.writeByte(image.getHeight());
		for (int pixel : image.getRGB(0, 0, image.getWidth(), image.getHeight(), null, 0, image.getWidth()))
		{
			out.writeInt(pixel);
		}
	}

	private BufferedImage[] getImages(String key, @Nullable String[] states) throws MojoExecutionException
	{
		final boolean hasStates = states != null;
		final int statesLength = hasStates ? states.length : 1;
		BufferedImage[] images = new BufferedImage[statesLength];

		for (int i = 0; i < statesLength; i++)
		{
			String postfix = ".";
			if (hasStates)
			{
				postfix += states[i] + ".";
			}
			postfix += "png";

			File imageFile = null;
			for (File sourceDirectory : sources)
			{
				// пока что считаем, что все файлы это png, а tiff добавим как понадобится
				imageFile = new File(sourceDirectory, key + postfix);
				if (imageFile.exists())
				{
					break;
				}
			}

			if (imageFile == null || !imageFile.exists())
			{
				throw new MojoExecutionException("Can't find image for " + key);
			}
			else
			{
				try
				{
					images[i] = ImageIO.read(imageFile);
				}
				catch (IOException e)
				{
					throw new MojoExecutionException("Can't read image " + imageFile, e);
				}
			}
		}

		return images;
	}

	private BufferedImage[] slice3H(BufferedImage[] sourceImages, Insets sliceSize)
	{
		BufferedImage[] images = new BufferedImage[sourceImages.length * 2];

		final int frameHeight = sourceImages[0].getHeight();
		final int rightImageX = sourceImages[0].getWidth() - sliceSize.right;
		int imageIndex = 0;
		for (BufferedImage sourceImage : sourceImages)
		{
			images[imageIndex++] = sourceImage.getSubimage(0, 0, sliceSize.left + 1, frameHeight);
			images[imageIndex++] = sourceImage.getSubimage(rightImageX, 0, sliceSize.right, frameHeight);
		}

		return images;
	}

	private void lazyWriteInsets(Insets insets, boolean isContent) throws IOException
	{
		if (insets == null)
		{
			out.writeByte(0);
		}
		else
		{
			out.writeByte(1);

			if (isContent)
			{
//				output.writeByte(contentInsets is TextInsets ? 1 : 0);
				out.writeByte(0);
			}

			out.writeByte(insets.left);
			out.writeByte(insets.top);
			out.writeByte(insets.right);
			out.writeByte(insets.bottom);
		}
	}
}