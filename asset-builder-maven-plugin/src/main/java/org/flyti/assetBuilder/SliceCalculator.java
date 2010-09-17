package org.flyti.assetBuilder;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.awt.image.Raster;

public final class SliceCalculator {
  /**
   * Для большинства изображений достаточно и 1, но для изображение Fluent PopUp Button, где стрелка отступает от края на несколько px — нужно именно такое значение
   * (иначе мы до стрелки не дойдем, посчитав и так что изображение уже не повторяется).
   */
  /**
   * Количество _непрерывных_ равных пикселей (отсчет от 0)
   * Учитывается только для top и right
   */
  private static final int DEFAULT_EQUAL_LENGTH = 4;

  private SliceCalculator() {
  }

  public static Insets calculate(BufferedImage image) {
    return calculate(image, null);
  }

  public static Insets calculate(BufferedImage image, Rectangle frameRectangle) {
    return calculate(image, frameRectangle, false, false, 0);
  }

  public static Insets calculate(BufferedImage image, Rectangle frameRectangle, boolean strict, boolean allSide, int minTop) {
    int equalLength = image.getWidth() > (DEFAULT_EQUAL_LENGTH * 3) ? DEFAULT_EQUAL_LENGTH : 1;

    Raster raster = frameRectangle == null ? image.getRaster() : image.getRaster().createChild(frameRectangle.x, frameRectangle.y, frameRectangle.width, frameRectangle.height, 0, 0, null);
    byte[] bands1 = new byte[raster.getNumBands()];
    byte[] bands2 = new byte[raster.getNumBands()];

    Insets sliceSize = new Insets(getUnrepeatableFromLeft(raster, bands1, bands2, strict, 1, 0), allSide ? getUnrepeatableFromTop(raster, bands1, bands2, strict, equalLength, minTop) : 0,
            getUnrepeatableFromRight(raster, bands1, bands2, strict, 1, 0), allSide ? getUnrepeatableFromBottom(raster, bands1, bands2, strict, 1, 0) : 0);
    if (sliceSize.getWidth() == raster.getWidth() || (allSide && sliceSize.getHeight() == raster.getHeight())) {
      throw new Error("can't find center area");
    }

    return sliceSize;
  }

  private static int getUnrepeatableFromLeft(Raster raster, byte[] bands1, byte[] bands2, boolean strict, int equalLength, int minLeft) {
    int equalCount = 0;
    int x = minLeft;
    int y = 0;
    int maxX = raster.getWidth() - 1;
    int maxY = raster.getHeight() - 1;

    raster.getDataElements(x++, y, bands1);

    while (true) {
      raster.getDataElements(x, y, bands2);
      if (!equalColor(bands1, bands2, strict)) {
        equalCount = 0;
      }
      else if (equalCount == equalLength) {
        if (y == maxY) {
          return x - equalCount - 1;
        }
        else {
          x = x - equalCount;
          equalCount = 0;
          y++;
          raster.getDataElements(x - 1, y, bands1);
          continue;
        }
      }
      else {
        equalCount++;
      }

      if (x == maxX) {
        throw new IllegalArgumentException("can't find center area");
      }
      else {
        x++;
        final byte[] bandsTemp = bands1;
        bands1 = bands2;
        bands2 = bandsTemp;
      }
    }
  }

  private static int getUnrepeatableFromRight(Raster raster, byte[] bands1, byte[] bands2, boolean strict, int equalLength, int minRight) {
    int equalCount = 0;
    int x = raster.getWidth() - 1 - minRight;
    int y = 0;
    int maxY = raster.getHeight() - 1;

    raster.getDataElements(x--, y, bands1);

    while (true) {
      raster.getDataElements(x, y, bands2);
      if (!equalColor(bands1, bands2, strict)) {
        equalCount = 0;
      }
      else if (equalCount == equalLength) {
        if (y == maxY) {
          return raster.getWidth() - x - equalCount - 2;
        }
        else {
          x = x + equalCount;
          equalCount = 0;
          y++;
          raster.getDataElements(x + 1, y, bands1);
          continue;
        }
      }
      else {
        equalCount++;
      }

      if (x == 0) {
        throw new IllegalArgumentException("can't find center area");
      }
      else {
        x--;
        final byte[] bandsTemp = bands1;
        bands1 = bands2;
        bands2 = bandsTemp;
      }
    }
  }

  private static int getUnrepeatableFromTop(Raster raster, byte[] bands1, byte[] bands2, boolean strict, int equalLength, int minTop) {
    int equalCount = 0;
    int x = 0;
    int y = minTop;
    int maxX = raster.getWidth() - 1;
    int maxY = raster.getHeight() - 1;

    raster.getDataElements(x, y++, bands1);

    while (true) {
      raster.getDataElements(x, y, bands2);
      if (!equalColor(bands1, bands2, strict)) {
        equalCount = 0;
      }
      else if (equalCount == equalLength) {
        if (x == maxX) {
          return y - equalCount - 1;
        }
        else {
          y = y - equalCount;
          equalCount = 0;
          x++;
          raster.getDataElements(x, y - 1, bands1);
          continue;
        }
      }
      else {
        equalCount++;
      }

      if (y == maxY) {
        throw new IllegalArgumentException("can't find center area");
      }
      else {
        y++;
        final byte[] bandsTemp = bands1;
        bands1 = bands2;
        bands2 = bandsTemp;
      }
    }
  }

  private static int getUnrepeatableFromBottom(Raster raster, byte[] bands1, byte[] bands2, boolean strict, int equalLength, int minBottom) {
    int equalCount = 0;
    int x = 0;
    int y = raster.getHeight() - 1 - minBottom;
    int maxX = raster.getWidth() - 1;

    raster.getDataElements(x, y--, bands1);

    while (true) {
      raster.getDataElements(x, y, bands2);
      if (!equalColor(bands1, bands2, strict)) {
        equalCount = 0;
      }
      else if (equalCount == equalLength) {
        if (x == maxX) {
          return raster.getHeight() - y - equalCount - 2;
        }
        else {
          y = y + equalCount;
          equalCount = 0;
          x++;
          raster.getDataElements(x, y + 1, bands1);
          continue;
        }
      }
      else {
        equalCount++;
      }

      if (y == 0) {
        throw new IllegalArgumentException("can't find center area");
      }
      else {
        y--;
        final byte[] bandsTemp = bands1;
        bands1 = bands2;
        bands2 = bandsTemp;
      }
    }
  }

  // в силу непонятных причин какой-либо из компонент цвета может отличаться на единицу это другого — поэтому мы считаем отклонение на единицу компонента цвета нормальным
  private static boolean equalColor(byte[] bands1, byte[] bands2, boolean strict) {
    // alpha must be equals in any case
    if (bands1.length == 4 && bands1[3] != bands2[3]) {
      return false;
    }

    if (strict) {
      for (int i = 0; i < 2; i++) {
        if (bands1[i] != bands2[i]) {
          return false;
        }
      }
    }
    else {
      for (int i = 0; i < 2; i++) {
        int diff = bands1[i] - bands2[i];
        if (diff > 1 || diff < -1) {
          return false;
        }
      }
    }

    return true;
  }
}
