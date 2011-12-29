package org.flyti.assetBuilder;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.IOException;

public final class Images {
  public static int getAppropriateBufferedImageType(BufferedImage original) {
    if (original.getType() == BufferedImage.TYPE_CUSTOM) {
      return original.getTransparency() == Transparency.TRANSLUCENT ? BufferedImage.TYPE_INT_ARGB : BufferedImage.TYPE_INT_RGB;
    }
    else {
      return original.getType();
    }
  }

  public static BufferedImage[] getScale3Edge(BufferedImage[] sourceImages, boolean horizontal) throws IOException {
    final int n = sourceImages.length;
    final BufferedImage[] images = new BufferedImage[n - (n / 3)];
    for (int i = 0, bitmapIndex = 0; i < n; i += 3) {
      final BufferedImage first = sourceImages[i];
      final BufferedImage center = sourceImages[i + 1];
      final BufferedImage firstAndFill;
      if (horizontal) {
        if (center.getWidth() != 1) {
          throw new IOException("The width of the center must be 1px");
        }

        final int firstWidth = first.getWidth();
        final int height = first.getHeight();
        firstAndFill = new BufferedImage(firstWidth + 1, height, getAppropriateBufferedImageType(first));
        // setRect causes problems with colorSpace
        firstAndFill.setRGB(0, 0, firstWidth, height, imageToRGB(first), 0, firstWidth);
        firstAndFill.setRGB(firstWidth, 0, 1, height, imageToRGB(center), 0, 1);
      }
      else {
        if (center.getHeight() != 1) {
          throw new IOException("The height of the center must be 1px");
        }

        final int width = first.getWidth();
        if (center.getWidth() != width) {
          throw new IOException("The width of the center must be equals first width");
        }

        final int firstHeight = first.getHeight();
        firstAndFill = new BufferedImage(width, firstHeight + 1, getAppropriateBufferedImageType(first));
        // setRect causes problems with colorSpace
        firstAndFill.setRGB(0, 0, width, firstHeight, imageToRGB(first), 0, width);
        firstAndFill.setRGB(0, firstHeight, width, 1, imageToRGB(center), 0, 1);
      }

      images[bitmapIndex++] = firstAndFill;
      images[bitmapIndex++] = sourceImages[i + 2];
    }

    return images;
  }

  public static int[] imageToRGB(BufferedImage image) {
    return image.getRGB(0, 0, image.getWidth(), image.getHeight(), null, 0, image.getWidth());
  }
}
