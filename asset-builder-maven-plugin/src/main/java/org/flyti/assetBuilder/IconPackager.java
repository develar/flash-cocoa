package org.flyti.assetBuilder;

import org.codehaus.plexus.util.DirectoryScanner;

import javax.imageio.ImageIO;
import java.io.File;
import java.io.IOException;
import java.util.List;

public class IconPackager {
  public static final String[] INCLUDES = {"**/*.png", "**/*.tiff"};

  public void pack(List<File> sourceDirectories, AssetOutputStream out) throws IOException {
    DirectoryScanner scanner = new DirectoryScanner();
    scanner.addDefaultExcludes();
    scanner.setIncludes(INCLUDES);

    for (File sourceDirectory : sourceDirectories) {
      File baseDirectory = new File(sourceDirectory, "icons");
      if (baseDirectory.exists()) {
        scanner.setBasedir(baseDirectory);
        scanner.scan();

        String[] filenames = scanner.getIncludedFiles();
        for (String filename : filenames) {
          out.writeUTF(filename.substring(0, filename.lastIndexOf('.')).replace('/', '.'));
          out.write(ImageIO.read(new File(baseDirectory, filename)));
        }
      }
    }
  }
}
