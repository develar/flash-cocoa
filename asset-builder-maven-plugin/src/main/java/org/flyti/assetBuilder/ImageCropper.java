package org.flyti.assetBuilder;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.Raster;

public final class ImageCropper {
  public static Rectangle cropSimilar(BufferedImage image) {
    final Raster raster = image.getRaster();
    final byte[] bands1 = new byte[raster.getNumBands()];
    final byte[] bands2 = new byte[raster.getNumBands()];

    Rectangle bounds = findNonTransparentBounds(image);
    if (bounds == null) {
      bounds = raster.getBounds();
    }

    int maxX = bounds.x + bounds.width - 1;
    int maxY = bounds.y + bounds.height - 1;

    int x = bounds.x;
    int y = maxY;

    // bottom
    raster.getDataElements(x, y--, bands1);
    while (true) {
      raster.getDataElements(x, y, bands2);
      if (!equalColor(bands1, bands2)) {
        int diff = maxY - (y + 1);
        if (diff > 0) {
          bounds.height -= diff;
          maxY -= diff;
        }
        break;
      }

      if (x < maxX) {
        raster.getDataElements(++x, y + 1, bands1);
      }
      else {
        if (y > bounds.y) {
          raster.getDataElements((x = 0), y--, bands1);
        }
        else {
          bounds.height = 1;
          maxY = bounds.y;
          break;
        }
      }
    }

    // right
    x = maxX;
    y = bounds.y;

    raster.getDataElements(x--, y, bands1);
    while (true) {
      raster.getDataElements(x, y, bands2);
      if (!equalColor(bands1, bands2)) {
        int diff = maxX - (x + 1);
        if (diff > 0) {
          bounds.width -= diff;
          maxX -= diff;
        }
        break;
      }

      if (y < maxY) {
        raster.getDataElements(x + 1, ++y, bands1);
      }
      else {
        if (x > bounds.x) {
          raster.getDataElements(x--, (y = 0), bands1);
        }
        else {
          bounds.width = 1;
          //noinspection UnusedAssignment
          maxX = bounds.x;
          break;
        }
      }
    }

    return bounds;
  }

  private static boolean equalColor(byte[] bands1, byte[] bands2) {
    for (int i = 0; i < bands1.length; i++) {
      if (bands1[i] != bands2[i]) {
        return false;
      }
    }

    return true;
  }

  public static Rectangle findNonTransparentBounds(BufferedImage image) {
    Raster raster = image.getRaster();
    byte[] bands = new byte[raster.getNumBands()];

    int y = getTransparentFromTop(raster, image.getColorModel(), bands);
    int bottom = getTransparentFromBottom(raster, image.getColorModel(), bands, y);
    int x = getTransparentFromLeft(raster, image.getColorModel(), bands, y, bottom);
    int width = getTransparentFromRight(raster, image.getColorModel(), bands, y, bottom) - x + 1;
    int height = bottom - y + 1;
    return (width == raster.getWidth() && height == raster.getHeight()) ? null : new Rectangle(x, y, width, height);
  }

  private static int getTransparentFromTop(Raster raster, ColorModel colorModel, byte[] bands) {
    int x = 0;
    int y = 0;
    int maxX = raster.getWidth() - 1;
    int maxY = raster.getHeight() - 1;

    while (true) {
      if (colorModel.getAlpha(raster.getDataElements(x, y, bands)) != 0) {
        return y;
      }

      if (x < maxX) {
        x++;
      }
      else {
        if (y < maxY) {
          x = 0;
          y++;
        }
        else {
          return raster.getHeight();
        }
      }
    }
  }

  private static int getTransparentFromBottom(Raster raster, ColorModel colorModel, byte[] bands, int minY) {
    int x = 0;
    int y = raster.getHeight() - 1;
    int maxX = raster.getWidth() - 1;

    while (true) {
      if (colorModel.getAlpha(raster.getDataElements(x, y, bands)) != 0) {
        return y;
      }

      if (x < maxX) {
        x++;
      }
      else {
        if (y > minY) {
          x = 0;
          y--;
        }
        else {
          return minY;
        }
      }
    }
  }

  private static int getTransparentFromLeft(Raster raster, ColorModel colorModel, byte[] bands, int minY, int maxY) {
    int x = 0;
    int y = minY;
    int maxX = raster.getWidth() - 1;

    int minNonTransparentX = maxX;

    while (true) {
      if (colorModel.getAlpha(raster.getDataElements(x, y, bands)) != 0) {
        if (y == maxY) {
          return Math.min(x, minNonTransparentX);
        }
        else if (x < minNonTransparentX) {
          minNonTransparentX = x;
        }
      }

      if (x < maxX) {
        x++;
      }
      else if (y < maxY) {
        x = 0;
        y++;
      }
    }
  }

  private static int getTransparentFromRight(Raster raster, ColorModel colorModel, byte[] bands, int minY, int maxY) {
    int x = 0;
    int y = minY;
    int maxX = raster.getWidth() - 1;

    int maxNonTransparentX = 0;

    while (true) {
      if (colorModel.getAlpha(raster.getDataElements(x, y, bands)) != 0) {
        if (y == maxY) {
          return Math.max(x, maxNonTransparentX);
        }
        else if (x > maxNonTransparentX) {
          maxNonTransparentX = x;
        }
      }

      if (x > 0) {
        x--;
      }
      else if (y < maxY) {
        x = maxX;
        y++;
      }
    }
  }
}
