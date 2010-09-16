package org.flyti.assetBuilder;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.awt.image.ColorModel;
import java.awt.image.Raster;

public final class ImageCropper {
  public static Rectangle findNonTransparentBounds(BufferedImage image) {
    Raster raster = image.getRaster();
    byte[] bands = new byte[raster.getNumBands()];

    int y = getTransparentFromTop(raster, image.getColorModel(), bands);
    int bottom = getTransparentFromBottom(raster, image.getColorModel(), bands, y);
    int x = getTransparentFromLeft(raster, image.getColorModel(), bands, y, bottom);
    return new Rectangle(x, y, getTransparentFromRight(raster, image.getColorModel(), bands, y, bottom) - x + 1, bottom - y + 1);
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
