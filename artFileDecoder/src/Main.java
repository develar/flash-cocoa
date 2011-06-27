import java.io.IOException;

public class Main {
  public static void main(String[] args)
    throws IOException {
    boolean encode = false;
    //if (args.length < 3) {
    //  System.out.println("Usage: java -jar ArtFileTool.jar -encode artFiles oldArtFile outputArtFile");
    //  System.out.println("Usage: java -jar ArtFileTool.jar -decode ArtFile folderToOutput");
    //  System.exit(1);
    //}
    //if (args[0].equals("-encode")) {
    //  encode = true;
    //}
    //else if (!args[0].equals("-decode")) {
    //  System.out.println("Usage: java -jar ArtFileTool.jar -encode artFiles oldArtFile outputArtFile");
    //  System.out.println("Usage: java -jar ArtFileTool.jar -decode ArtFile folderToOutput");
    //  System.exit(1);
    //}

    if (encode) {
      Encoder artEncoder = new Encoder(args[1], args[2], args[3]);
      artEncoder.setUpEnv();
      artEncoder.createHeader();
      artEncoder.copyOldStuff();
      for (int i = 0; i < artEncoder.getNumOfFiles(); i++) {
        artEncoder.writeNewImages(i);
      }
      System.out.println("ArtFile.bin successfully created in " + args[3]);
    }
    else {
      //Decoder artDecoder = new Decoder(args[1], args[2]);
      Decoder artDecoder = new Decoder("/Users/develar/ArtFile.bin", "../artFiles");
      artDecoder.openFile();
      artDecoder.getAttributes();

      artDecoder.MakeNameArray();
      for (int i = 0; i < artDecoder.getNumOfFiles(); i++) {
        artDecoder.getArtOffsetAndSetTags(i);
        artDecoder.readArtData();
        artDecoder.writeImages(i);
      }
      //System.out.println("ArtFile.bin Successfully Decoded to " + args[2]);
    }
  }
}