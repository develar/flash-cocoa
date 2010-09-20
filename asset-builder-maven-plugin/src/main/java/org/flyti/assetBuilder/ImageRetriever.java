package org.flyti.assetBuilder;

import org.apache.maven.plugin.MojoExecutionException;

import javax.media.jai.JAI;
import javax.media.jai.RenderedOp;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.*;

// если для key найдено изображение для какого-либо состояния, то мы считаем, что и все остальные изображения в этой же source directory
public class ImageRetriever {
  private List<File> sources;

  private final Map<File, String[]> directoryContentCache;

  public ImageRetriever(List<File> sources) {
    this.sources = sources;

    directoryContentCache = new HashMap<File, String[]>(sources.size());
  }

  private AppleAssetNameComparator appleAssetNameComparator;
  private AssetNameComparator assetNameComparator;

  public BufferedImage[] getImages(String key) throws MojoExecutionException, IOException {
    if (assetNameComparator == null) {
      assetNameComparator = new AssetNameComparator();
    }
    assetNameComparator.setPrefixLength(key.length());
    return getImages(key, assetNameComparator);
  }

  public BufferedImage getImage(String key) throws MojoExecutionException, IOException {
    for (File sourceDirectory : sources) {
      String[] files = directoryContentCache.get(sourceDirectory);
      if (files == null) {
        files = sourceDirectory.list();
        Arrays.sort(files);
        directoryContentCache.put(sourceDirectory, files);
      }

      int index = binarySearch(files, key);
      if (index > -1) {
          return JAI.create("fileload", sourceDirectory.getPath() + File.separator + files[index]).getAsBufferedImage();
      }
    }

    throw new MojoExecutionException("Can't find image for " + key);
  }

  // Ищет изображения как они в Apple app resources
  public BufferedImage[] getImagesFromAppleResources(final String appleResource) throws MojoExecutionException, IOException {
    if (appleAssetNameComparator == null) {
      appleAssetNameComparator = new AppleAssetNameComparator();
    }
    appleAssetNameComparator.setPrefixLength(appleResource.length());
    return getImages(appleResource, appleAssetNameComparator);
  }

  private BufferedImage[] getImages(final String name, Comparator<String> assetNameComparator) throws MojoExecutionException, IOException {
    for (File sourceDirectory : sources) {
      String[] files = directoryContentCache.get(sourceDirectory);
      if (files == null) {
        files = sourceDirectory.list();
        Arrays.sort(files);
        directoryContentCache.put(sourceDirectory, files);
      }

      int index = binarySearch(files, name);
      if (index > -1) {
        if (index > 0) {
          do {
            index--;
          }
          while (index > -1 && files[index].startsWith(name));
          index++;
        }

        int endIndex = index + 1;
        while (endIndex < files.length && files[endIndex].startsWith(name)) {
          endIndex++;
        }

        final int imageFilesLength = endIndex - index;
        BufferedImage[] images = new BufferedImage[imageFilesLength];
        String[] imageFiles = new String[imageFilesLength];
        System.arraycopy(files, index, imageFiles, 0, imageFilesLength);

        Arrays.sort(imageFiles, assetNameComparator);
        System.out.print(Arrays.toString(imageFiles) + "\n");
        for (int i = 0; i < imageFilesLength; i++) {
          images[i] = JAI.create("fileload", sourceDirectory.getPath() + File.separator + imageFiles[i]).getAsBufferedImage();
        }

        return images;
      }
    }

    throw new MojoExecutionException("Can't find image for " + name);
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

  private static class AssetNameComparator implements Comparator<String> {
    private int start;

    public void setPrefixLength(int prefixLength) {
      start = prefixLength + 2/* . + o(ff|n|ver)*/;
    }

    @Override
    public int compare(String s1, String s2) {
      return getWeight(s1) - getWeight(s2);
    }

    private int getWeight(String s) {
      switch (s.charAt(start)) {
        case 'f':
          return 1;

        case 'n':
          return 2;

        case 'v':
          return 3;

        default:
          throw new IllegalArgumentException("unknown " + s);
      }
    }
  }

  private static class AppleAssetNameComparator implements Comparator<String> {
    private int prefixLength;
    private int start = -1;

    public void setPrefixLength(int prefixLength) {
      start = -1;
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

    private int getWeight(String s) {
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

        case 'O': // Off/On
          if (s.charAt(start + 1) == 'f') {
            weight = 1000;
            stateIndex = 4;
          }
          else {
            weight = 2000;
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