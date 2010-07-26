package org.flyti.assetBuilder;

import org.codehaus.plexus.util.DirectoryScanner;

import javax.imageio.ImageIO;
import java.io.File;
import java.io.IOException;

public class IconPackager
{
	public static final String[] INCLUDES = {"*.png", "*.tiff"};

	public void pack(File sourceDirectory, AssetOutputStream out) throws IOException
	{
		DirectoryScanner scanner = new DirectoryScanner();
		scanner.addDefaultExcludes();
		scanner.setIncludes(INCLUDES);

		scanner.setBasedir( sourceDirectory );
        scanner.scan();

		String[] iconFilenames = scanner.getIncludedFiles();

		out.writeByte(iconFilenames.length);
		for (String iconFilename : iconFilenames)
		{
			out.writeUTF(iconFilename.substring(0, iconFilename.lastIndexOf(".")));
			out.write(ImageIO.read(new File(sourceDirectory, iconFilename)));
		}
	}
}
