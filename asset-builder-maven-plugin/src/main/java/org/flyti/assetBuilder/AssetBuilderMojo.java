package org.flyti.assetBuilder;

import org.apache.commons.io.filefilter.SuffixFileFilter;
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
@SuppressWarnings({"UnusedDeclaration"})
public class AssetBuilderMojo extends AbstractMojo
{
	private static final String[] DEFAULT_STATES = {"off", "on"};

	private static final FileFilter ASSET_FILE_FILTER = new SuffixFileFilter(new String[]{".png"});

	/**
     * @parameter expression="${asset.builder..skip}"
     */
    @SuppressWarnings({"UnusedDeclaration"})
	private boolean skip;

	/**
     * @parameter expression="${project}"
     * @required
     * @readonly
     */
	@SuppressWarnings({"UnusedDeclaration"})
	private MavenProject project;

	/**
     * @parameter default-value="${project.build.directory}/assets"
     */
    @SuppressWarnings({"UnusedDeclaration"})
	private File output;

	/**
     * @parameter default-value="src/main/resources/assets.xml"
     */
	@SuppressWarnings({"UnusedDeclaration"})
	private File descriptor;

	private List<File> sources;

	private AssetOutputStream out = null;

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
			out = new AssetOutputStream(new BufferedOutputStream(new FileOutputStream(output)));
//			out = new AssetOutputStream(new DeflaterOutputStream(new FileOutputStream(output), new Deflater(Deflater.BEST_COMPRESSION)));
			buildBorders(assetSet.borders);

			new IconPackager().pack(sources, out);

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
			out.writeUTF(border.key.indexOf('.') == -1 ? (key + ".border") : key);
			out.writeByte(borderType.ordinal());

			BufferedImage[] sourceImages = getImages(key, borderType == BorderType.OneBitmap ? null : DEFAULT_STATES);

			switch (borderType)
			{
				case Scale3EdgeHBitmap:
				{
					// мы рассчитываем slice size для изображения on, а не off состояния, так как зачастую именно оно дает наиболее полный slice size,
					// иначе для off оно будет маленьким и его не хватит для on (на примере Fluent PopUp Button в on будет обрезана стрелка) — мы то считаем один раз для всех состояний.
					// Такая политика — расчет по одному изображения для всех состояний на 100% работает для Aqua UI, а во Fluent UI есть вот такие заморочки.
					out.write(slice3H(sourceImages, sliceCalculator.calculate(sourceImages[1], false, false)));
				}
				break;

				case OneBitmap:
				{
					out.write(sourceImages[0]);
				}
				break;

				case Scale1Bitmap:
				{
					out.write(sourceImages);
				}
				break;
			}

			lazyWriteInsets(border.contentInsets, true);
			lazyWriteInsets(border.frameInsets, false);
		}
	}

	private BufferedImage[] getImages(String key, String[] states) throws MojoExecutionException, IOException
	{
		final boolean hasStates = states != null;
		final int statesLength = hasStates ? states.length : 1;

		// если для key найдено изображение для какого-либо состояния, то мы считаем, что и все остальные изображения там же
		for (File sourceDirectory : sources)
		{
			boolean found = false;

			String postfix = ".";
			if (hasStates)
			{
				postfix += states[0] + ".";
			}
			postfix += "png";

			File imageFile = new File(sourceDirectory, key + postfix);
			if (imageFile.exists())
			{
				BufferedImage[] images = new BufferedImage[statesLength];
				images[0] = ImageIO.read(imageFile);
				if (hasStates)
				{
					for (int i = 1; i < statesLength; i++)
					{
						images[i] = ImageIO.read(new File(sourceDirectory, key + "." + states[i] + ".png"));
					}
				}

				return images;
			}
			else if (hasStates)
			{
				File imageDirectory = new File(sourceDirectory, key);
				if (imageDirectory.exists())
				{
					File[] files = imageDirectory.listFiles(ASSET_FILE_FILTER);
					BufferedImage[] images = new BufferedImage[files.length];

					Arrays.sort(files, new Comparator<File>()
					{
						@Override
						public int compare(File o1, File o2)
						{
							if (o1.getName().startsWith("off"))
							{
								return o2.getName().startsWith("off") ? (o1.getName().length() - o2.getName().length()) : -1;
							}
							else if (o1.getName().startsWith("on"))
							{
								return o2.getName().startsWith("on") ? (o1.getName().length() - o2.getName().length()) : 1;
							}

							throw new IllegalArgumentException("Image for unknown state: " + o1);
						}
					});

					for (int i = 0, filesLength = files.length; i < filesLength; i++)
					{
						images[i] = ImageIO.read(files[i]);
					}

					return images;
				}
			}
		}

		throw new MojoExecutionException("Can't find image for " + key);
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