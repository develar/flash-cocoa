package cocoa.plaf.aqua.assetBuilder;

import org.flyti.assetBuilder.AssetOutputStream;
import org.flyti.assetBuilder.BorderType;
import org.flyti.assetBuilder.SliceCalculator;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;

/**
 * 4 (off, on, highlight off, highlight on) first, 4 middle, 4 last and 2 separator (off == highlight off, on == highlight on)
 * В отличие от прочих border, этот нам проще отрисовать самим по логике, — скин будет умным.
 */
class SegmentBorderBuilder {
  private final File artFilesRoot;
  private File artFiles;
  private final File usedArtFiles;

  public SegmentBorderBuilder(File artFilesRoot) {
    usedArtFiles = new File("/Users/develar/test/usedAssets");
    //noinspection ResultOfMethodCallIgnored
    usedArtFiles.mkdirs();

    this.artFilesRoot = artFilesRoot;
  }

  public void build(AssetOutputStream out) throws IOException {
    artFiles = new File(artFilesRoot, "segment");
    doBuild(out, new String[]{"clear/", "blue/", "clear/on.", "blue/pressed."}, new String[]{"clear/", "blue/"});

    artFiles = new File(artFilesRoot, "tbsegments");
    // selecting state for unselected equals selecting state for selected,
    // currently, we don't reduce final border size (later, we can introduce sym links)
    //doBuild(out, new String[]{"active/", "on/pressed.", "on/", "on/pressed."}, new String[]{"active/", "on/"});
  }

  private int getAppropriateBufferedImageType(BufferedImage original) {
    if (original.getType() == BufferedImage.TYPE_CUSTOM) {
      return original.getTransparency() == Transparency.TRANSLUCENT ? BufferedImage.TYPE_INT_ARGB : BufferedImage.TYPE_INT_RGB;
    }
    else {
      return original.getType();
    }
  }

  public void doBuild(AssetOutputStream out, String[] indexToPath, String[] separatorIndexToPath) throws IOException {
    for (String controlSize : new String[]{"regular", "small"}) {
      out.writeUTF("Segment." + controlSize);
      out.writeByte(BorderType.Scale1.ordinal());
      // image count
      out.writeByte(3 * 4 + 2);

      Pair[] middle = new Pair[4];
      // backgrounds
      for (int part = 0; part < 3; part += 2) {
        for (int i = 0; i < 4; i++) {
          BufferedImage image = readImage(indexToPath[i] + controlSize + "-" + part + ".png");
          if (part == 0) {
            // textured rounded left doesn't have repetable area, we need appent middle to it
            BufferedImage fill = readImage(indexToPath[i] + controlSize + "-" + (part + 1) + ".png");
            if (image.getHeight() != fill.getHeight()) {
              throw new IllegalStateException();
            }

            BufferedImage leftAndFill = new BufferedImage(image.getWidth() + fill.getWidth(), image.getHeight(), getAppropriateBufferedImageType(image));
            leftAndFill.setRGB(0, 0, image.getWidth(), image.getHeight(), AssetOutputStream.imageToRGB(image), 0, image.getWidth());
            leftAndFill.setRGB(image.getWidth(), 0, fill.getWidth(), image.getHeight(), AssetOutputStream.imageToRGB(fill), 0, fill.getWidth());

            Rectangle frameRectangle = SliceCalculator.trimRight(leftAndFill);
            out.write(leftAndFill, frameRectangle);

            frameRectangle.x += frameRectangle.width;
            frameRectangle.width = 1;
            assert middle != null;
            middle[i] = new Pair(leftAndFill, frameRectangle);
          }
          else {
            out.write(image, SliceCalculator.trimLeft(image));
          }
        }

        if (part == 0) {
          assert middle != null;
          for (Pair pair : middle) {
            out.write(pair.image, pair.frameRectangle);
          }

          middle = null;
        }
      }

      // separators
      for (int i = 0; i < 2; i++) {
        BufferedImage image = readImage(separatorIndexToPath[i] + (controlSize.equals("small") ? "separator." + controlSize : controlSize + ".separator") + "-1.png");
        out.trimAndWrite(image);
      }

      // insets, content insets are equal for regular/small
      out.writeByte(1);
      out.writeByte(-1);
      out.writeByte(10);
      out.writeByte(0);
      out.writeByte(10);
      out.writeByte(4);

      // no frameInsets
      out.writeByte(0);
    }
  }

  private static class Pair {
    final BufferedImage image;
    final Rectangle frameRectangle;

    private Pair(BufferedImage image, Rectangle frameRectangle) {
      this.image = image;
      this.frameRectangle = frameRectangle;
    }
  }
  
  private BufferedImage readImage(String subFilepath) throws IOException {
    File file = new File(artFiles, subFilepath);
    copyFile(file, new File(usedArtFiles, subFilepath));
    return ImageIO.read(file);
  }

  @SuppressWarnings("ResultOfMethodCallIgnored")
  private static void copyFile(File sourceFile, File destFile) throws IOException {
    if (!destFile.exists()) {
      destFile.getParentFile().mkdir();
      destFile.createNewFile();
    }

    FileChannel source = null;
    FileChannel destination = null;

    try {
      source = new FileInputStream(sourceFile).getChannel();
      destination = new FileOutputStream(destFile).getChannel();
      destination.transferFrom(source, 0, source.size());
    }
    finally {
      if (source != null) {
        source.close();
      }
      if (destination != null) {
        destination.close();
      }
    }

    destFile.setLastModified(sourceFile.lastModified());
  }
}
