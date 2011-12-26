package cocoa.plaf.aqua.assetBuilder;

import org.flyti.assetBuilder.AssetOutputStream;

import java.io.*;

public class Builder {
  public static void main(String[] args) throws IOException {
    new Builder(args[0], "/Users/develar/test/artFiles");
  }

  public Builder(String outputFilename, String artFiles) throws IOException {
    final AssetOutputStream out = new AssetOutputStream(new BufferedOutputStream(new FileOutputStream(new File(outputFilename))));
    out.writeByte(2);
    SegmentBorderBuilder segmentBorderBuilder = new SegmentBorderBuilder(new File(artFiles));
    segmentBorderBuilder.build(out);
    out.close();
  }
}
