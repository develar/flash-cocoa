package cocoa.plaf.aqua.assetBuilder;

import org.flyti.assetBuilder.AssetOutputStream;
import org.flyti.assetBuilder.BorderType;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;

/**
 * 4 (off, on, highlight off, highlight on) left, 4 middle, 4 right and 2 separator (off == highlight off, on == highlight on)
 * В отличие от прочих border, этот нам проще отрисовать самим по логике, — скин будет умным.
 */
class SegmentBorderBuilder {
  private final File artFiles;
  private final File usedArtFiles;

  private static final String[] indexToPath = {"clear/inactive.", "clear/on.", "blue/", "blue/pressed."};
  
  public SegmentBorderBuilder(File artFiles) {
    this.artFiles = new File(artFiles, "segment");
    usedArtFiles = new File("/Users/develar/Documents/cocoa/aquaLaF/borderBuilder/usedAssets");
    //noinspection ResultOfMethodCallIgnored
    usedArtFiles.mkdirs();
  }

  public void build(AssetOutputStream out) throws IOException {
    for (String controlSize : new String[]{"regular", "small"}) {
      out.writeUTF("Segment." + controlSize);
      out.writeByte(BorderType.Scale1.ordinal());
      // image count
      out.writeByte(3 * 4 + 2);

      // backgrounds
      for (int part = 0; part < 3; part++) {
        for (int i = 0; i < 4; i++) {
          BufferedImage image = readImage(indexToPath[i] + controlSize + "-" + part + ".png");
          out.trimAndWrite(image);
        }
      }

      // separators
      for (int i = 0; i < 2; i++) {
        BufferedImage image = readImage((i == 0 ? "clear/inactive." : "blue/") + (controlSize.equals("small") ? "separator." + controlSize : controlSize + ".separator") + "-1.png");
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
