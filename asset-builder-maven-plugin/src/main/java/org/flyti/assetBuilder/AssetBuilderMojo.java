package org.flyti.assetBuilder;

import org.apache.maven.artifact.Artifact;
import org.apache.maven.model.Resource;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.project.MavenProject;
import org.codehaus.plexus.util.IOUtil;
import org.simpleframework.xml.Serializer;
import org.simpleframework.xml.core.Persister;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.*;
import java.util.List;

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
     * @parameter expression="${asset.builder.skip}"
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

		//noinspection ResultOfMethodCallIgnored
		output.getParentFile().mkdirs();

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
			//noinspection ResultOfMethodCallIgnored
			projectResourceDirectoryCache.getParentFile().mkdirs();
			new ObjectOutputStream(new FileOutputStream(projectResourceDirectoryCache)).writeObject(projectResourceDirectoryMap);
		}
	}

	private void buildBorders(List<Border> borders) throws IOException, MojoExecutionException
	{
		out.writeByte(borders.size());

		SliceCalculator sliceCalculator = new SliceCalculator();

		ImageRetriever imageRetriever = new ImageRetriever(sources);

		for (Border border : borders)
		{
			BorderType borderType = BorderType.valueOf(border.type);

			final String key = border.subkey == null ? border.key : (border.subkey + "." + border.key);
			out.writeUTF(border.key.indexOf('.') == -1 ? (key + ".border") : key);
			out.writeByte(borderType.ordinal());

//			if (border.appleResource == null)
			final BufferedImage[] sourceImages;
			if (border.appleResource == null)
			{
				sourceImages = imageRetriever.getImages(key, borderType == BorderType.OneBitmap ? null : DEFAULT_STATES);
			}
			else
			{
				sourceImages = imageRetriever.getImagesFromAppleResources(border.appleResource, new String[]{"N", "P"});
			}

			switch (borderType)
			{
				case Scale3EdgeHBitmap:
				{
					if (border.appleResource == null)
					{
						// мы рассчитываем slice size для изображения on, а не off состояния, так как зачастую именно оно дает наиболее полный slice size,
						// иначе для off оно будет маленьким и его не хватит для on (на примере Fluent PopUp Button в on будет обрезана стрелка) — мы то считаем один раз для всех состояний.
						// Такая политика — расчет по одному изображения для всех состояний на 100% работает для Aqua UI, а во Fluent UI есть вот такие заморочки.
						out.write(slice3H(sourceImages, sliceCalculator.calculate(sourceImages[1], false, false)));
					}
					else
					{
						out.write(joinButtonAppleResources(sourceImages));
					}
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

	private BufferedImage[] joinButtonAppleResources(BufferedImage[] sourceImages) throws IOException, MojoExecutionException
	{
		final int n  = sourceImages.length;
		BufferedImage[] images = new BufferedImage[n - (n / 3)];
		for (int i = 0, bitmapIndex = 0; i < n; i += 3)
		{
			BufferedImage left = sourceImages[i];
			BufferedImage center = sourceImages[i + 1];

			if (center.getWidth() != 1)
			{
				throw new MojoExecutionException("The width of the center must be 1px");
			}

			final int leftWidth = left.getWidth();
			final int height = left.getHeight();

			BufferedImage leftAndFill = new BufferedImage(leftWidth + 1, height, getAppropriateBufferedImageType(left));
			// с setRect были проблемы с colorSpace
			leftAndFill.setRGB(0, 0, leftWidth, height, imageToRGB(left), 0, leftWidth);
			leftAndFill.setRGB(leftWidth, 0, 1, height, imageToRGB(center), 0, 1);

			images[bitmapIndex++] = leftAndFill;
			images[bitmapIndex++] = sourceImages[i + 2];
		}

		return images;
	}

	private int[] imageToRGB(BufferedImage image)
	{
		return image.getRGB(0, 0, image.getWidth(), image.getHeight(), null, 0, image.getWidth());
	}

	private int getAppropriateBufferedImageType(BufferedImage original)
	{
		if (original.getType() == BufferedImage.TYPE_CUSTOM)
		{
			return original.getTransparency() == Transparency.TRANSLUCENT ? BufferedImage.TYPE_INT_ARGB : BufferedImage.TYPE_INT_RGB;
		}
		else
		{
			return original.getType();
		}
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
				out.writeByte(insets.truncatedTailMargin);
			}

			out.writeByte(insets.left);
			out.writeByte(insets.top);
			out.writeByte(insets.right);
			out.writeByte(insets.bottom);
		}
	}
}