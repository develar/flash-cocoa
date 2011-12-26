package org.flyti.assetBuilder;

import org.yaml.snakeyaml.TypeDescription;
import org.yaml.snakeyaml.Yaml;
import org.yaml.snakeyaml.constructor.Constructor;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

public class AssetBuilder {
  private final File descriptor;
  private final File output;
  private final List<File> sources;
  private AssetOutputStream out;

  public static void main(String[] args) throws IOException {
    if (args.length != 3) {
      throw new IllegalArgumentException("Usage: AssetBuilderMojo <descriptorFile> <outputFile> <source1,source2,source3>");
    }
    String descriptorFile = args[0];
    String outputFile = args[1];
    String sourceFiles = args[2];

    List<File> sources = new ArrayList<File>();
    StringTokenizer t = new StringTokenizer(sourceFiles, ",");
    while (t.hasMoreTokens()) {
      sources.add(new File(t.nextToken()));
    }

    new AssetBuilder(new File(descriptorFile), new File(outputFile), sources).build();
  }

  public AssetBuilder(File descriptor, File output, List<File> sources) {
    this.descriptor = descriptor;
    this.output = output;
    this.sources = sources;
  }

  public void build() throws IOException {
    final Constructor constructor = new Constructor(AssetSet.class);
    final TypeDescription borderDescription = new TypeDescription(AssetSet.class);
    borderDescription.putListPropertyType("borders", Border.class);
    constructor.addTypeDescription(borderDescription);
    final Yaml yaml = new Yaml(constructor);
    final AssetSet assetSet = (AssetSet)yaml.load(new BufferedInputStream(new FileInputStream(descriptor)));

    //noinspection ResultOfMethodCallIgnored
    output.getParentFile().mkdirs();

    try {
      out = new AssetOutputStream(new BufferedOutputStream(new FileOutputStream(output)));
      buildBorders(assetSet.borders);

      new IconPackager().pack(sources, out);

      out.flush();
    }
    finally {
      if (out != null) {
        try {
          out.close();
        }
        catch (IOException ignored) {
        }
      }
    }
  }

  private void buildBorders(List<Border> borders) throws IOException {
    out.writeByte(borders.size());

    ImageRetriever imageRetriever = new ImageRetriever(sources);
    CompoundImageReader compoundImageReader = null;

    for (Border border : borders) {
      final String key = border.subkey == null ? border.key : (border.subkey + "." + border.key);
      out.writeUTF(border.key.indexOf('.') == -1 ? (key + ".b") : key);

      if (border.type == BorderType.One || border.type == BorderType.Scale9Edge) {
        out.writeByte(border.type.ordinal());
        final BufferedImage sourceImage;
        if (border.source == null) {
          sourceImage = imageRetriever.getImage(key);
        }
        else {
          if (compoundImageReader == null) {
            File compoundImageFile = border.source.file;
            if (compoundImageFile == null) {
              compoundImageFile = sources.get(0);
            }
            else if (!compoundImageFile.isAbsolute()) {
              compoundImageFile = new File(descriptor.getParent(), compoundImageFile.getPath());
            }
            compoundImageReader = new CompoundImageReader(compoundImageFile);
          }

          sourceImage = compoundImageReader.getImage(border.source.rectangle);
        }

        switch (border.type) {
          case One:
            out.write(sourceImage);
            break;

          case Scale9Edge:
            out.write(slice9(sourceImage, border.minTop));
            break;
        }
      }
      else {
        final BufferedImage[] sourceImages = border.appleResource == null ? imageRetriever.getImages(key) : imageRetriever.getImagesFromAppleResources(border.appleResource);
        if (border.type == BorderType.Scale3EdgeH) {
          if (border.appleResource == null) {
            if (sourceImages.length == 1 || sourceImages[0].getWidth() == sourceImages[1].getWidth()) {
              out.writeByte(border.type.ordinal());
              // мы рассчитываем slice size для изображения on, а не off состояния, так как зачастую именно оно дает наиболее полный slice size,
              // иначе для off оно будет маленьким и его не хватит для on (на примере Fluent PopUp Button в on будет обрезана стрелка) — мы то считаем один раз для всех состояний.
              // Такая политика — расчет по одному изображения для всех состояний на 100% работает для Aqua UI, а во Fluent UI есть вот такие заморочки.
              out.write(slice3H(sourceImages, SliceCalculator.calculate(sourceImages[sourceImages.length == 1 ? 0 : 1])));
            }
            else { // see note in Scale3EdgeHBitmapBorderWithSmartFrameInsets, only for Fluent
              out.writeByte(BorderType.Scale3EdgeHWithSmartFrameInsets.ordinal());
              out.write(slice3H(sourceImages));
            }
          }
          else {
            out.writeByte(border.type.ordinal());
            out.write(joinButtonAppleResources(sourceImages));
          }
        }
        else {
          out.writeByte(border.type.ordinal());
          if (border.trim) {
            out.trimAndWrite(sourceImages);
          }
          else {
            out.write(sourceImages);
          }
        }
      }

      lazyWriteInsets(border.contentInsets, true);
      lazyWriteInsets(border.frameInsets, false);
    }
  }

  private BufferedImage[] joinButtonAppleResources(BufferedImage[] sourceImages) throws IOException {
    final int n = sourceImages.length;
    BufferedImage[] images = new BufferedImage[n - (n / 3)];
    for (int i = 0, bitmapIndex = 0; i < n; i += 3) {
      BufferedImage left = sourceImages[i];
      BufferedImage center = sourceImages[i + 1];

      if (center.getWidth() != 1) {
        throw new IOException("The width of the center must be 1px");
      }

      final int leftWidth = left.getWidth();
      final int height = left.getHeight();

      BufferedImage leftAndFill = new BufferedImage(leftWidth + 1, height, getAppropriateBufferedImageType(left));
      // с setRect были проблемы с colorSpace
      leftAndFill.setRGB(0, 0, leftWidth, height, AssetOutputStream.imageToRGB(left), 0, leftWidth);
      leftAndFill.setRGB(leftWidth, 0, 1, height, AssetOutputStream.imageToRGB(center), 0, 1);

      images[bitmapIndex++] = leftAndFill;
      images[bitmapIndex++] = sourceImages[i + 2];
    }

    return images;
  }

  private int getAppropriateBufferedImageType(BufferedImage original) {
    if (original.getType() == BufferedImage.TYPE_CUSTOM) {
      return original.getTransparency() == Transparency.TRANSLUCENT ? BufferedImage.TYPE_INT_ARGB : BufferedImage.TYPE_INT_RGB;
    }
    else {
      return original.getType();
    }
  }

  private BufferedImage[] slice3H(BufferedImage[] sourceImages, Insets sliceSize) {
    BufferedImage[] images = new BufferedImage[sourceImages.length * 2];
    final int frameHeight = sourceImages[0].getHeight();
    final int rightImageX = sourceImages[0].getWidth() - sliceSize.right;
    int imageIndex = 0;
    for (BufferedImage sourceImage : sourceImages) {
      images[imageIndex++] = sourceImage.getSubimage(0, 0, sliceSize.left + 1, frameHeight);
      images[imageIndex++] = sourceImage.getSubimage(rightImageX, 0, sliceSize.right, frameHeight);
    }

    return images;
  }

  private BufferedImage[] slice3H(BufferedImage[] sourceImages) {
    BufferedImage[] images = new BufferedImage[sourceImages.length * 2];
    int imageIndex = 0;
    for (BufferedImage sourceImage : sourceImages) {
      Insets sliceSize = SliceCalculator.calculate(sourceImage);
      images[imageIndex++] = sourceImage.getSubimage(0, 0, sliceSize.left + 1, sourceImage.getHeight());
      images[imageIndex++] = sourceImage.getSubimage(sourceImage.getWidth() - sliceSize.right, 0, sliceSize.right, sourceImage.getHeight());
    }

    return images;
  }

  private BufferedImage[] slice9(BufferedImage sourceImage, int minTop) {
    BufferedImage[] images = new BufferedImage[4];
    Rectangle frameRectangle = ImageCropper.findNonTransparentBounds(sourceImage);
    Insets sliceSize = SliceCalculator.calculate(sourceImage, frameRectangle, true, true, minTop);
    if (frameRectangle == null) {
      frameRectangle = sourceImage.getRaster().getBounds();
    }

    final int topHeight = sliceSize.top + 1;
    images[0] = sourceImage.getSubimage(frameRectangle.x, frameRectangle.y, sliceSize.left + 1, topHeight);
    final int rightX = frameRectangle.x + frameRectangle.width - sliceSize.right;
    images[1] = sourceImage.getSubimage(rightX, frameRectangle.y, sliceSize.right, topHeight);
    final int y = frameRectangle.y + frameRectangle.height - sliceSize.bottom;
    images[2] = sourceImage.getSubimage(frameRectangle.x, y, sliceSize.left + 1, sliceSize.bottom);
    images[3] = sourceImage.getSubimage(rightX, y, sliceSize.right, sliceSize.bottom);

    dump(images);
    return images;
  }

  @SuppressWarnings({"UnusedDeclaration"})
  private static void dump(BufferedImage[] images) {
    try {
      for (int i = 0, imagesLength = images.length; i < imagesLength; i++) {
        ImageIO.write(images[i], "png", new BufferedOutputStream(new FileOutputStream("/Users/develar/t" + i + ".png")));
      }
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }

  private void lazyWriteInsets(Insets insets, boolean isContent) throws IOException {
    if (insets == null) {
      out.writeByte(0);
    }
    else {
      out.writeByte(1);

      if (isContent) {
        out.writeByte(insets.truncatedTailMargin);
      }

      out.writeByte(insets.left);
      out.writeByte(insets.top);
      out.writeByte(insets.right);
      out.writeByte(insets.bottom);
    }
  }
}
