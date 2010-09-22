package org.flyti.assetBuilder;

import org.apache.maven.plugin.MojoExecutionException;

import javax.media.jai.JAI;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FilenameFilter;
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
  private AssetNameComparatorImpl assetNameComparator;

  public BufferedImage[] getImages(String key) throws MojoExecutionException, IOException {
    if (assetNameComparator == null) {
      assetNameComparator = new AssetNameComparatorImpl();
    }
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
    return getImages(appleResource, appleAssetNameComparator);
  }

  private BufferedImage[] getImages(final String name, AssetNameComparator assetNameComparator) throws MojoExecutionException, IOException {
    for (File sourceDirectory : sources) {
      String[] files = directoryContentCache.get(sourceDirectory);
      if (files == null) {
        files = sourceDirectory.list();
        Arrays.sort(files);
        directoryContentCache.put(sourceDirectory, files);
      }

      int index = binarySearch(files, name);
      if (index > -1) {
        final int imageFilesLength;
        final String[] imageFiles;
        final StringBuilder rootDir = new StringBuilder(sourceDirectory.getPath() + File.separator);
        // is directory
        if (files[index].length() == name.length()) {
          imageFiles = new File(sourceDirectory, name).list(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
              return name.charAt(0) != '.' && name.lastIndexOf('.') != -1;
            }
          });
          imageFilesLength = imageFiles.length;

          assetNameComparator.setPrefixLength(0);
          rootDir.append(name).append(File.separator);
        }
        else {
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

          imageFilesLength = endIndex - index;
          imageFiles = new String[imageFilesLength];
          System.arraycopy(files, index, imageFiles, 0, imageFilesLength);
          assetNameComparator.setPrefixLength(name.length());
        }

        Arrays.sort(imageFiles, assetNameComparator);
        
        BufferedImage[] images = new BufferedImage[imageFilesLength];
//        System.out.print(Arrays.toString(imageFiles) + "\n");
        for (int i = 0; i < imageFilesLength; i++) {
          images[i] = JAI.create("fileload", rootDir + imageFiles[i]).getAsBufferedImage();
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
}