package org.flyti.assetBuilder;

import org.junit.Test;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.InputStream;

import static org.junit.Assert.*;

public class SliceCalculatorTest {
  @Test
  public void testSimple() throws IOException {
    BufferedImage image = ImageIO.read(getLocalResource("Untitled.png"));
    Insets sliceSize = SliceCalculator.calculate(image, null, true, true, 0);
    assertTrue(sliceSize.left == 10);
    assertTrue(sliceSize.top == 10);
    assertTrue(sliceSize.right == 10);
    assertTrue(sliceSize.bottom == 10);
  }

  @Test
  public void testDifficult() throws IOException {
    BufferedImage image = ImageIO.read(getLocalResource("Window.png"));
    Insets sliceSize = SliceCalculator.calculate(image, null, true, true, 0);
    assertTrue(sliceSize.left == 16);
    assertTrue(sliceSize.top == 21);
    assertTrue(sliceSize.right == 16);
    assertTrue(sliceSize.bottom == 17);
  }

  @Test
  public void testSmall() throws IOException {
    BufferedImage image = ImageIO.read(getLocalResource("TabLabel.off.png"));
    Insets sliceSize = SliceCalculator.calculate(image, null, true, true, 0);
    assertTrue(sliceSize.left == 4);
    assertTrue(sliceSize.top == 3);
    assertTrue(sliceSize.right == 4);
    assertTrue(sliceSize.bottom == 3);
  }

  public static InputStream getLocalResource(String name) {
    return SliceCalculatorTest.class.getClassLoader().getResourceAsStream(name);
  }
}
