import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;

public class Encoder {
  private String artFolder;
  private Decoder oldArtFile;
  private RandomAccessFile newArtFile;
  private RandomAccessFile oldFile;
  private int globalctr = 0;
  BufferedImage newImage;
  private int lastOffset = 0;

  public Encoder(String readFolder, String oldFilePath, String newArt) throws IOException {
    this.artFolder = (readFolder + "/");
    this.oldArtFile = new Decoder(oldFilePath);
    this.oldFile = new RandomAccessFile(oldFilePath, "rw");
    this.newArtFile = new RandomAccessFile(newArt, "rw");
    this.lastOffset = (int)this.newArtFile.length();
  }

  public void setUpEnv() throws IOException {
    this.oldArtFile.openFile();
    this.oldArtFile.getAttributes();
    this.oldArtFile.MakeNameArray();
  }

  public void createHeader()
    throws IOException {
    this.newArtFile.writeShort(Short.reverseBytes((short)3224));
    this.newArtFile.writeShort(this.oldArtFile.getUnknownFieldInHeader());
    this.newArtFile.writeInt(Integer.reverseBytes(this.oldArtFile.getTagCount()));
    this.newArtFile.writeInt(Integer.reverseBytes(24));
    this.newArtFile.writeInt(Integer.reverseBytes(1536));
    this.newArtFile.writeInt(Integer.reverseBytes(3271));
    this.newArtFile.writeInt(Integer.reverseBytes(41960));
  }

  public void copyOldStuff() throws IOException {
    this.oldFile.seek(24L);
    byte[] oldTags = new byte[5836796];
    this.oldFile.read(oldTags);
    this.newArtFile.write(oldTags);
  }

  public int getNumOfFiles() {
    return this.oldArtFile.getNumOfFiles();
  }

  public String getFolderToReadFrom(int fileNum) throws IOException {
    String dir = "";
    this.oldArtFile.getArtOffsetAndSetTags(fileNum);
    for (int j = 0; j <= this.oldArtFile.getNumOfTags(); j++) {
      dir = dir + this.oldArtFile.names[this.oldArtFile.tags[j]] + "/";
    }

    return dir;
  }

  public void writeNewImages(int fileNum)
    throws IOException {
    int lastSubOffset;

    int offset = this.oldArtFile.getArtOffsetAndSetTags(fileNum);
    this.newArtFile.seek(this.newArtFile.length());
    this.oldArtFile.readArtData();
    String dir = getFolderToReadFrom(fileNum);

    for (int i = 0; i < this.oldArtFile.numOfImages; i++) {
      if (this.oldArtFile.subimageHeights[i] == 0) {
        continue;
      }
      File readFromDir = new File(this.artFolder + dir + this.globalctr + ".png");
      this.newImage = ImageIO.read(readFromDir);

      int w = this.newImage.getWidth();
      int h = this.newImage.getHeight();
      int[] readArray = new int[w * h];

      int[] imgArray = this.newImage.getRGB(0, 0, w, h, readArray, 0, w);
      int k = 0;
      this.newArtFile.seek(this.newArtFile.length());

      while (k < readArray.length) {
        this.newArtFile.writeInt(readArray[k]);

        k++;
      }

      lastSubOffset = (int)(this.newArtFile.getFilePointer() - 4 * readArray.length - offset);

      this.newArtFile.seek(offset + 32 + 4 * i);
      this.newArtFile.writeInt(Integer.reverseBytes(lastSubOffset));
      this.newArtFile.seek(offset + 68 + 2 * i);
      this.newArtFile.writeShort(Short.reverseBytes((short)w));
      this.newArtFile.seek(offset + 86 + 2 * i);
      this.newArtFile.writeShort(Short.reverseBytes((short)h));
      this.globalctr += 1;
    }
    this.lastOffset = (int)this.newArtFile.getFilePointer();
  }
}