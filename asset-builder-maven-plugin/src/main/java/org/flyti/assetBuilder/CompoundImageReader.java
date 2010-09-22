package org.flyti.assetBuilder;

import javax.media.jai.JAI;
import javax.media.jai.RenderedOp;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;

public class CompoundImageReader {
  private RenderedOp image;

  public CompoundImageReader(File source) {
    image = JAI.create("fileload", source.getPath());
  }

  public BufferedImage getImage(Rectangle rectangle) {
    return image.getAsBufferedImage(rectangle, null);
  }
}
