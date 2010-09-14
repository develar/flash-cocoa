package org.flyti.assetBuilder;

import org.apache.commons.io.filefilter.SuffixFileFilter;
import org.apache.maven.plugin.MojoExecutionException;

import javax.imageio.ImageIO;
import javax.media.jai.JAI;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.util.*;

// если для key найдено изображение для какого-либо состояния, то мы считаем, что и все остальные изображения в этой же source directory
public class ImageRetriever {
  private static final FileFilter ASSET_FILE_FILTER = new SuffixFileFilter(new String[]{".png"});

  private List<File> sources;

  private Map<File, String[]> directoryContentCache;

  public ImageRetriever(List<File> sources) {
    this.sources = sources;

    directoryContentCache = new HashMap<File, String[]>(sources.size());
  }

  // Ищет изображения как они в Apple app resources
  public BufferedImage[] getImagesFromAppleResources(final String appleResource) throws MojoExecutionException, IOException {
    for (File sourceDirectory : sources) {
      String[] files = directoryContentCache.get(sourceDirectory);
      if (files == null) {
        files = sourceDirectory.list();
        Arrays.sort(files);
        directoryContentCache.put(sourceDirectory, files);
      }

      int index = binarySearch(files, appleResource);
      if (index > -1) {
        if (index > 0) {
          //noinspection StatementWithEmptyBody
          while (index > 0 && files[--index].startsWith(appleResource));
          index++;
        }

        int endIndex = index + 1;
        //noinspection StatementWithEmptyBody
        while (endIndex < files.length && files[endIndex].startsWith(appleResource)) {
          endIndex++;
        }

        final int imageFilesLength = endIndex - index;
        BufferedImage[] images = new BufferedImage[imageFilesLength];
        String[] imageFiles = new String[imageFilesLength];
        System.arraycopy(files, index, imageFiles, 0, imageFilesLength);

        Arrays.sort(imageFiles, new StringComparator(appleResource.length()));
        System.out.print(Arrays.toString(imageFiles) + "\n");
        for (int i = 0; i < imageFilesLength; i++) {
          images[i] = JAI.create("fileload", sourceDirectory.getPath() + File.separator + imageFiles[i]).getAsBufferedImage();
        }

        return images;
      }
    }

    throw new MojoExecutionException("Can't find image for " + appleResource);
  }

  private static int binarySearch(String[] list, String prefix) {
    int low = 0;
    int high = list.length - 1;

    final int prefixLength = prefix.length();

    while (low <= high) {
      int mid = (low + high) >>> 1;
      String midValue = list[mid];
      if (midValue.length() > prefixLength) {
        midValue = midValue.substring(0, prefixLength);
      }

      int cmp = midValue.compareTo(prefix);
      if (cmp < 0) {
        low = mid + 1;
      }
      else if (cmp > 0) {
        high = mid - 1;
      }
      else {
        return mid; // key found
      }
    }

    return -(low + 1);  // key not found.
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

  private static class StringComparator implements Comparator<String> {
    private int prefixLength;
    private int start = -1;

    public StringComparator(int prefixLength) {
      this.prefixLength = prefixLength;
    }

    @Override
    public int compare(String s1, String s2) {
      if (start == -1) {
        final char testChar = s1.charAt(prefixLength);
        start = testChar == '_' || testChar == '-' ? prefixLength + 1 : prefixLength;
      }
      return getWeight(s1) - getWeight(s2);
    }

    public int getWeight(String s) {
      final int weight;
      final int stateIndex;
      switch (s.charAt(start)) {
        case 'L': // Left
          if (s.charAt(start + 4) == 'C') {
            return 1;
          }
          else {
            weight = 10;
            stateIndex = 5;
          }
          break;

        case 'F': // Fill
          if (s.charAt(start + 4) == '.') {
            return 2;
          }
          else {
            weight = 20;
            stateIndex = 5;
          }
          break;

        case 'R':
          if (s.charAt(start + 1) == 'i') {
            if (s.charAt(start + 5) == 'C') {
              return 3;
            }
            else {
              weight = 30; // Right
              stateIndex = 6;
            }
          }
          else {
            return 4; // Rollover
          }
          break;

        case 'N': // Normal
          return 1;
        case 'P': // Pressed
          return 2;
        case 'D': // Disabled
          return 3;

        case 'O':
          if (s.charAt(start + 1) == 'f') {
            weight = 10;
            stateIndex = 4;
          }
          else {
            weight = 20;
            stateIndex = 3;
          }
          break;

        // -top, -fill, -bottom
        case 't': return 0;
        case 'f': return 1;
        case 'b': return 2;

        default:
          throw new IllegalArgumentException("unknown " + s);
      }

      switch (s.charAt(start + stateIndex)) {
        case 'N':
          return weight + 100;

        case 'P':
          return weight + 200;

        case 'D':
          return weight + 300;

        default:
          throw new IllegalArgumentException("unknown " + s);
      }
    }
  }
}