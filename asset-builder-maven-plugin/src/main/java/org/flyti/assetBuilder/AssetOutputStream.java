package org.flyti.assetBuilder;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class AssetOutputStream extends DataOutputStream {
  public AssetOutputStream(OutputStream out) {
    super(out);
  }

  public static int[] imageToRGB(BufferedImage image) {
    return image.getRGB(0, 0, image.getWidth(), image.getHeight(), null, 0, image.getWidth());
  }

  public void write(BufferedImage image) throws IOException {
    writeByte(image.getWidth());
    writeByte(image.getHeight());
    for (int pixel : imageToRGB(image)) {
      writeInt(pixel);
    }
  }

  public void write(BufferedImage[] images) throws IOException {
    writeByte(images.length);
    for (BufferedImage image : images) {
      write(image);
    }
  }

  public void trimAndWrite(BufferedImage[] images) throws IOException {
    writeByte(images.length);
    for (BufferedImage image : images) {
      trimAndWrite(image);
    }
  }

  public void trimAndWrite(BufferedImage image) throws IOException {
    write(image, ImageCropper.findNonTransparentBounds(image));
  }

  public void write(BufferedImage image, Rectangle frameRectangle) throws IOException {
    if (frameRectangle == null) {
      write(image);
      return;
    }

    writeByte(frameRectangle.width);
    writeByte(frameRectangle.height);
    for (int pixel : image.getRGB(frameRectangle.x, frameRectangle.y, frameRectangle.width, frameRectangle.height, null, 0, frameRectangle.width)) {
      writeInt(pixel);
    }
  }
}
