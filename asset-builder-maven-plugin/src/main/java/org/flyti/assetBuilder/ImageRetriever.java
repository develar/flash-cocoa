package org.flyti.assetBuilder;

import org.apache.commons.io.filefilter.SuffixFileFilter;
import org.apache.maven.plugin.MojoExecutionException;

import javax.imageio.ImageIO;
import javax.media.jai.JAI;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

public class ImageRetriever {
  private static final FileFilter ASSET_FILE_FILTER = new SuffixFileFilter(new String[]{".png"});
  private static final String[] BUTTON_IMAGE_PARTS = {"Left", "Fill", "Right"};
  private static final String[] CHECK_BOX_STATE_PARTS = {"Off", "On"};

  private static final String[] DEFAULT_APPLE_STATES = {"N", "P"};

  private List<File> sources;

  public ImageRetriever(List<File> sources) {
    this.sources = sources;
  }

  // Ищет изображения как они в Apple app resources
  public BufferedImage[] getImagesFromAppleResources(final String appleResource) throws MojoExecutionException, IOException {
    if (appleResource.endsWith("_")) {
      return getImagesForCheckBoxFromAppleResources(appleResource, DEFAULT_APPLE_STATES);
    }
    else {
      return getImagesForButtonFromAppleResources(appleResource, DEFAULT_APPLE_STATES);
    }
  }

  private BufferedImage[] getImagesForButtonFromAppleResources(final String appleResource, final String[] states) throws MojoExecutionException, IOException {
    BufferedImage[] images = new BufferedImage[3 * 2];

    int imageIndex = 0;
    sl:
    for (File sourceDirectory : sources) {
      final String prefix = sourceDirectory.getAbsolutePath() + File.separator + appleResource;
      for (int i = 0; i < 2; i++) {
        for (String partName : BUTTON_IMAGE_PARTS) {
          File file = new File(prefix + partName + "-" + states[i] + ".tiff");
          if (imageIndex == 0 && !file.exists()) {
            continue sl;
          }

          images[imageIndex++] = JAI.create("fileload", file.getAbsolutePath()).getAsBufferedImage();
        }
      }

      // optional disabled state
      File file = new File(prefix + BUTTON_IMAGE_PARTS[0] + "-D.tiff");
      if (file.exists()) {
        BufferedImage[] imagesWithDisabled = new BufferedImage[3 * 3];
        System.arraycopy(images, 0, imagesWithDisabled, 0, 6);
        images = imagesWithDisabled;

        for (String partName : BUTTON_IMAGE_PARTS) {
          images[imageIndex++] = JAI.create("fileload", prefix + partName + "-D.tiff").getAsBufferedImage();
        }
      }

      return images;
    }

    throw new MojoExecutionException("Can't find image for " + appleResource);
  }

  private BufferedImage[] getImagesForCheckBoxFromAppleResources(final String appleResource, final String[] states) throws MojoExecutionException, IOException {
    BufferedImage[] images = new BufferedImage[4];

    int imageIndex = 0;
    sl:
    for (File sourceDirectory : sources) {
      final String prefix = sourceDirectory.getAbsolutePath() + File.separator + appleResource;
      for (int i = 0; i < 2; i++) {
        for (String partName : CHECK_BOX_STATE_PARTS) {
          File file = new File(prefix + partName + "-" + states[i] + ".tiff");
          if (imageIndex == 0 && !file.exists()) {
            continue sl;
          }

          images[imageIndex++] = JAI.create("fileload", file.getAbsolutePath()).getAsBufferedImage();
        }
      }

      return images;
    }

    throw new MojoExecutionException("Can't find image for " + appleResource);
  }

  public BufferedImage[] getImages(String key, String[] states) throws MojoExecutionException, IOException {
    final boolean hasStates = states != null;
    final int statesLength = hasStates ? states.length : 1;

    // если для key найдено изображение для какого-либо состояния, то мы считаем, что и все остальные изображения там же
    for (File sourceDirectory : sources) {
      String postfix = ".";
      if (hasStates) {
        postfix += states[0] + ".";
      }
      postfix += "png";

      File imageFile = new File(sourceDirectory, key + postfix);
      if (imageFile.exists()) {
        ArrayList<BufferedImage> images = new ArrayList<BufferedImage>(statesLength);
        images.add(ImageIO.read(imageFile));
        if (hasStates) {
          for (int i = 1; i < statesLength; i++) {
            final File file = new File(sourceDirectory, key + "." + states[i] + ".png");
            if (file.exists()) {
              images.add(ImageIO.read(file));
            }
          }
        }

        return images.toArray(new BufferedImage[images.size()]);
      }
      else if (hasStates) {
        File imageDirectory = new File(sourceDirectory, key);
        if (imageDirectory.exists()) {
          File[] files = imageDirectory.listFiles(ASSET_FILE_FILTER);
          BufferedImage[] images = new BufferedImage[files.length];

          Arrays.sort(files, new Comparator<File>() {
            @Override
            public int compare(File o1, File o2) {
              if (o1.getName().startsWith("off")) {
                return o2.getName().startsWith("off") ? (o1.getName().length() - o2.getName().length()) : -1;
              }
              else if (o1.getName().startsWith("on")) {
                return o2.getName().startsWith("on") ? (o1.getName().length() - o2.getName().length()) : 1;
              }
              else {
                return 1;
              }
            }
          });

          for (int i = 0, filesLength = files.length; i < filesLength; i++) {
            images[i] = ImageIO.read(files[i]);
          }

          return images;
        }
      }
    }

    throw new MojoExecutionException("Can't find image for " + key);
  }
}