package cocoa.plaf.aqua.assetBuilder;

import org.flyti.assetBuilder.BorderType;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.color.ColorSpace;
import java.awt.image.*;
import java.io.*;

public class Printer {
  private final File outputDir;

  public Printer(File outputDir) {
    this.outputDir = outputDir;
    //noinspection ResultOfMethodCallIgnored
    outputDir.mkdirs();
  }

  public static void main(String[] args) throws IOException {
    new Printer(new File("/Users/develar/d")).print(new File("/Users/develar/Documents/cocoa/aquaLaF/resources/segmentBorders"));
  }

  private void print(File file) throws IOException {
    final DataInputStream in = new DataInputStream(new BufferedInputStream(new FileInputStream(file)));
    final int borderCount = in.readUnsignedByte();
    for (int i = 0; i < borderCount; i++) {
      String filename = in.readUTF();
      final int borderType = in.readUnsignedByte();
      if (borderType == BorderType.Scale1.ordinal()) {
        printImages(in, filename);
      }
      else {
        throw new IOException("Unknown border type "  + borderType);
      }
    }
  }

  private void printImages(DataInputStream in, String filename) throws IOException {
    final int imageCount = in.readUnsignedByte();
    for (int i = 0; i < imageCount; i++) {
      final int w = in.readUnsignedByte();
      if (w == 0) {
        return;
      }

      final int h = in.readUnsignedByte();
      
      final ComponentColorModel colorModel = new ComponentColorModel(ColorSpace.getInstance(ColorSpace.CS_sRGB), true, false, Transparency.TRANSLUCENT, DataBuffer.TYPE_BYTE);
      final int[] bandOffsets = {1, 2, 3, 0};

      final byte[] argb = loadBytes(in, w * h * 4);
      BufferedImage image = new BufferedImage(colorModel,
        (WritableRaster)Raster.createRaster(new PixelInterleavedSampleModel(DataBuffer.TYPE_BYTE, w, h, 4, w * 4, bandOffsets),
          new DataBufferByte(argb, argb.length), null), false, null);

      ImageIO.write(image, "png", new File(outputDir, filename + '-' + i + ".png"));
    }

    if (in.readByte() == 1) {
      @SuppressWarnings("UnusedDeclaration")
      int first = in.readByte();
      new Insets(in.readByte(), in.readByte(), in.readByte(), in.readByte());
    }
    if (in.readByte() == 1) {
      new Insets(in.readByte(), in.readByte(), in.readByte(), in.readByte());
    }
  }

  private static byte[] loadBytes(InputStream stream, int length) throws IOException {
    byte[] bytes = new byte[length];
    int count = 0;
    while (count < length) {
      int n = stream.read(bytes, count, length - count);
      if (n <= 0) break;
      count += n;
    }
    return bytes;
  }
}
