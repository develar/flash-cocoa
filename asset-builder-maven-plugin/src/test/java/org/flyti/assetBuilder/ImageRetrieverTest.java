package org.flyti.assetBuilder;

import org.junit.Test;

import javax.media.jai.JAI;
import java.awt.image.BufferedImage;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.*;
import static org.junit.Assert.assertTrue;

public class ImageRetrieverTest {
  @Test
  public void testGetImagesFromAppleResources() throws Exception {
    List<File> sources = new ArrayList<File>(1);
    sources.add(new File("aquaLaF/src/main/resources/hud").getCanonicalFile());

    ImageRetriever imageRetriever = new ImageRetriever(sources);
    BufferedImage[] images = imageRetriever.getImagesFromAppleResources("HUD-Checkbox");
    assertTrue(compareImage(images[0], JAI.create("fileload", sources.get(0).getPath() + File.separator + "HUD-Checkbox_Off-N.tiff").getAsBufferedImage()));
    assertTrue(compareImage(images[1], JAI.create("fileload", sources.get(0).getPath() + File.separator + "HUD-Checkbox_Off-P.tiff").getAsBufferedImage()));
    assertTrue(compareImage(images[2], JAI.create("fileload", sources.get(0).getPath() + File.separator + "HUD-Checkbox_On-N.tiff").getAsBufferedImage()));
    assertTrue(compareImage(images[3], JAI.create("fileload", sources.get(0).getPath() + File.separator + "HUD-Checkbox_On-P.tiff").getAsBufferedImage()));
  }

  @Test
  public void testGetImagesFromDir() throws Exception {
    List<File> sources = new ArrayList<File>(1);
    sources.add(new File("asset-builder-maven-plugin/src/test/resources").getCanonicalFile());

    ImageRetriever imageRetriever = new ImageRetriever(sources);
    BufferedImage[] images = imageRetriever.getImages("CheckBox");
    assertTrue(images.length == 6);
  }

  private boolean compareImage(BufferedImage image1, BufferedImage image2) {
    return Arrays.equals(image1.getRGB(0, 0, image1.getWidth(), image1.getHeight(), null, 0, image1.getWidth()), image2.getRGB(0, 0, image2.getWidth(), image2.getHeight(), null, 0, image2.getWidth()));
  }
}
