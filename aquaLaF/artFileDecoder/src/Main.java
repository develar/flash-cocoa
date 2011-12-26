import java.io.IOException;

public class Main {
  public static void main(String[] args)
    throws IOException {
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


    //Decoder artDecoder = new Decoder(args[1], args[2]);
    //Decoder decoder = new Decoder("/System/Library/PrivateFrameworks/CoreUI.framework/Versions/A/Resources/ArtFile.bin", "/Users/develar/test/artFiles");
    new Decoder("aquaLaF/artFileDecoder/ArtFile.bin", System.getProperty("user.home") + "/test/artFiles").decode();
    //System.out.println("ArtFile.bin Successfully Decoded to " + args[2]);

  }
}