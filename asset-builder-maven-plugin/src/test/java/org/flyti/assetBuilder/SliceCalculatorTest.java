package org.flyti.assetBuilder;

import org.junit.Test;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;

import static org.junit.Assert.*;

public class SliceCalculatorTest {
  @Test
  public void testCalcaluteSimple() throws IOException {
    BufferedImage image = ImageIO.read(getLocalResource("Untitled.png"));
    Insets sliceSize = SliceCalculator.calculate(image, null, true, true, 0);
    assertTrue(sliceSize.left == 10);
    assertTrue(sliceSize.top == 10);
    assertTrue(sliceSize.right == 10);
    assertTrue(sliceSize.bottom == 10);
  }

  @Test
  public void testCompile() throws IOException {
    BufferedImage image = ImageIO.read(getLocalResource("Window.png"));
    Insets sliceSize = SliceCalculator.calculate(image, null, true, true, 0);
    assertTrue(sliceSize.left == 17);
    assertTrue(sliceSize.top == 21);
    assertTrue(sliceSize.right == 20);
    assertTrue(sliceSize.bottom == 17);
  }

  public static InputStream getLocalResource(String name) {
    return SliceCalculatorTest.class.getClassLoader().getResourceAsStream(name);
  }
}
