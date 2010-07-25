package org.flyti.assetBuilder;

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
	private static final String[] states = {"off", "on"};
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

	private File[] sources;

	@Override
	public void execute() throws MojoExecutionException, MojoFailureException
	{
		if (skip)
		{
			getLog().warn("Skipping generate assets");
			return;
		}

		setUpImageDirectories();

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

		DataOutputStream outputStream = null;
		try
		{
			outputStream = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(output)));
			buildBorders(assetSet.borders, outputStream);
			outputStream.flush();
		}
		catch (IOException e)
		{
			throw new MojoExecutionException("Can't write to output file", e);
		}
		finally
		{
			IOUtil.close(outputStream);
		}
	}

	private void setUpImageDirectories()
	{
		@SuppressWarnings({"unchecked"})
		List<Resource> resources = (List<Resource>) project.getResources();
		final int resourcesSize = resources.size();
		final int resourceDirectoriesOffset = 0;
		sources = new File[resourcesSize + 1];
//		sources = new File[resourcesSize + (imageDirectories == null ? 0 : imageDirectories.length)];
//		if (imageDirectories != null)
//		{
//			System.arraycopy(imageDirectories, 0, sources, 0, imageDirectories.length);
//			for (File imageDirectory : imageDirectories)
//			{
//				if (!imageDirectory.exists())
//				{
//					throw new MojoExecutionException("Image directory " + imageDirectory + " does not exists");
//				}
//			}
//		}

		for (int i = 0; i < resourcesSize; i++)
		{
			final String resourceDirectory = resources.get(i).getDirectory();
			//noinspection PointlessArithmeticExpression
			sources[i + resourceDirectoriesOffset] = new File(resourceDirectory);
		}

		// @todo надо получать из SWC
		sources[sources.length - 1] = new File("/Users/develar/workspace/XpressPages/common/fluentSkin/blue/src/main/resources");
	}

	private void buildBorders(List<Border> borders, DataOutput output) throws IOException, MojoExecutionException
	{
		output.writeByte(borders.size());

		SliceCalculator sliceCalculator = new SliceCalculator();

		for (Border border : borders)
		{
			BorderType borderType = BorderType.valueOf(border.type);
			output.writeUTF(border.key);
			output.writeByte(borderType.ordinal());

			BufferedImage[] sourceImages = getImages(border.key, states);

			Insets sliceSize = sliceCalculator.calculate(sourceImages[0], false, false);
			BufferedImage[] finalImages = slice3H(sourceImages, sliceSize);

			output.writeByte(finalImages.length);

			for (BufferedImage image : finalImages)
			{
				output.writeByte(image.getWidth());
				output.writeByte(image.getHeight());
				for (int pixel : image.getRGB(0, 0, image.getWidth(), image.getHeight(), null, 0, image.getWidth()))
				{
					output.writeInt(pixel);
				}
			}

			if (border.insets == null)
			{
				output.writeByte(0);
			}
			else
			{
				output.writeByte(1);
				writeInsets(output, border.insets);
			}

			lazyWriteFrameInsets(output, null);

//			switch (borderType)
//			{
//				case Scale3EdgeHBitmap:
//				{
//
//				}
//			}
		}
	}

	private BufferedImage[] getImages(String key, String[] states) throws MojoExecutionException
	{
		BufferedImage[] images = new BufferedImage[states.length];

		for (int i = 0, statesLength = states.length; i < statesLength; i++)
		{
			File imageFile = null;
			final String state = states[i];
			for (File sourceDirectory : sources)
			{
				// пока что считаем, что все файлы это png, а tiff добавим как понадобится
				imageFile = new File(sourceDirectory, key + "." + state + ".png");
				if (imageFile.exists())
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

			if (imageFile == null || !imageFile.exists())
			{
				throw new MojoExecutionException("Can't find image for " + key);
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

	private void writeInsets(DataOutput output, Insets insets) throws IOException
	{
//		output.writeByte(insets is TextInsets ? 1 : 0);
		output.writeByte(0);
		output.writeByte(insets.left);
		output.writeByte(insets.top);
		output.writeByte(insets.right);
		output.writeByte(insets.bottom);

//		if (insets is TextInsets)
//		{
//			output.writeByte(TextInsets(insets).truncatedTailMargin);
//		}
	}

	protected void lazyWriteFrameInsets(DataOutput output, Insets insets) throws IOException
	{
//		if (insets == EMPTY_FRAME_INSETS)
		//noinspection ConstantIfStatement
		if (true)
		{
			output.writeByte(0);
		}
		else
		{
			output.writeByte(1);
			writeInsets(output, insets);
		}
	}
}