import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class Decoder {
  private final String fp;
  private RandomAccessFile artFile;
  public int numOfImages = 0;

  private short fileCount = 0;
  private int tagCount = 0;
  private short unknownShort = 0;
  private int tagDescOffset = 0;
  private int tagNamesOffset = 0;
  private int fileDescOffset = 0;
  private int fileDataSectionOffset = 0;
  private int artFileStructOffset;
  public short artRows;
  private File outputDir;
  public short artColumns;
  public int[] subimageOffsets;
  public short[] subimageWidths;
  public short[] subimageHeights;
  public String[] names = new String[183];
  public int[] tags = new int[8];
  private int numOfTags = 0;
  public int[] imageArray;

  @SuppressWarnings("ResultOfMethodCallIgnored")
  public Decoder(String filepath, String output) {
    fp = filepath;
    outputDir = new File(output);
    if (outputDir.exists()) {
      outputDir.renameTo(new File(output + "_old_" + Math.random() * 100));
    }

    outputDir = new File(output);
    outputDir.mkdirs();
  }

  public Decoder(String filepath) {
    fp = filepath;
  }

  public void openFile()
    throws IOException {
    artFile = new RandomAccessFile(fp, "rw");
  }

  public void getAttributes() throws IOException {
    fileCount = Short.reverseBytes(artFile.readShort());
    unknownShort = artFile.readShort();
    tagCount = Integer.reverseBytes(artFile.readInt());
    tagDescOffset = Integer.reverseBytes(artFile.readInt());
    tagNamesOffset = Integer.reverseBytes(artFile.readInt());
    fileDescOffset = Integer.reverseBytes(artFile.readInt());
    fileDataSectionOffset = Integer.reverseBytes(artFile.readInt());
  }

  public int getNumOfFiles() {
    return fileCount;
  }

  public short getUnknownFieldInHeader() {
    return unknownShort;
  }

  public int getTagCount() {
    return tagCount;
  }

  public int getNumOfTags() {
    return numOfTags;
  }

  public int getArtOffsetAndSetTags(int fileNum) throws IOException {
    artFile.seek(fileDescOffset + 12 * fileNum);
    artFileStructOffset = (fileDataSectionOffset + Integer.reverseBytes(artFile.readInt()));

    for (int i = 0; i < 8; i++) {
      int curTag = artFile.readByte() & 0xFF;
      if (curTag == 0) {
        numOfTags = (i - 1);
        break;
      }
      tags[i] = curTag;
    }

    return artFileStructOffset;
  }

  public void MakeNameArray()
    throws IOException {
    for (int l = 0; l < 150; l++) {
      int numOfChars = 0;
      artFile.seek(tagDescOffset + 8 * l);
      int offset = Integer.reverseBytes(artFile.readInt());
      int index = artFile.readByte() & 0xFF;

      artFile.seek(offset + tagNamesOffset);

      while (artFile.readByte() != 0) {
        numOfChars++;
      }
      artFile.seek(artFile.getFilePointer() - (numOfChars + 1));
      byte[] chars = new byte[numOfChars];
      artFile.read(chars);
      String name = new String(chars, "UTF8");
      names[index] = name;
    }
  }

  public void readArtData()
    throws IOException {
    artFile.seek(artFileStructOffset);
    artRows = Short.reverseBytes(artFile.readShort());

    artColumns = Short.reverseBytes(artFile.readShort());

    numOfImages = (artRows * artColumns);

    artFile.readInt();
    artFile.readInt();
    artFile.readInt();
    artFile.readInt();
    artFile.readInt();
    artFile.readInt();
    artFile.readInt();
    subimageOffsets = new int[9];
    int i = 0;

    while (i < 9) {
      subimageOffsets[i] = Integer.reverseBytes(artFile.readInt());

      i++;
    }
    subimageWidths = new short[9];
    i = 0;

    while (i < 9) {
      subimageWidths[i] = Short.reverseBytes(artFile.readShort());

      i++;
    }
    i = 0;

    subimageHeights = new short[9];
    while (i < 9) {
      subimageHeights[i] = Short.reverseBytes(artFile.readShort());

      i++;
    }
  }

  private final Set<String> duplicateGuard = new HashSet<String>();

  @SuppressWarnings({"ResultOfMethodCallIgnored"})
  public void writeImages(int fileNum) throws IOException {
    MessageDigest md;
    try {
      md = MessageDigest.getInstance("SHA-512");
    }
    catch (NoSuchAlgorithmException e) {
      e.printStackTrace();
      return;
    }

    int duplicateCount = 0;
    for (int j = 0; j < numOfImages; j++) {
      artFile.seek(getArtOffsetAndSetTags(fileNum) + subimageOffsets[j]);
      if ((subimageWidths[j] == 0) || (subimageHeights[j] == 0)) {
        continue;
      }
      imageArray = new int[subimageWidths[j] * subimageHeights[j]];
      byte[] hashBuffer = new byte[imageArray.length * 4];
      int k = 0;
      int h = 0;
      while (k < imageArray.length) {
        final int v = artFile.readInt();
        imageArray[k] = v;

        hashBuffer[h++] = (byte)((v >>> 24) & 0xFF);
        hashBuffer[h++] = (byte)((v >>> 16) & 0xFF);
        hashBuffer[h++] = (byte)((v >>> 8) & 0xFF);
        hashBuffer[h++] = (byte)(v & 0xFF);

        k++;
      }

      final String digest = convertToHex(md.digest(hashBuffer));
      md.reset();
      if (duplicateGuard.contains(digest)) {
        duplicateCount++;
        continue;
      }

      duplicateGuard.add(digest);
      
      BufferedImage image = new BufferedImage(subimageWidths[j], subimageHeights[j], 2);
      image.setRGB(0, 0, subimageWidths[j], subimageHeights[j], imageArray, 0, subimageWidths[j]);

      File dir = new File(outputDir, names[tags[0]] + "/" + names[tags[1]]);
      dir.mkdirs();
      StringBuilder filenameBuilder = new StringBuilder();
      for (int i = 2; i <= numOfTags; i++) {
        filenameBuilder.append(names[tags[i]]).append(".");
      }
      final String subLocalPath = filenameBuilder.toString();
      final String key = dir.getPath() + "/" + subLocalPath;
      filenameBuilder.append("png");
      final String localPath = filenameBuilder.toString();

      Integer counter = pathCounter.get(key);
      File file;
      if (counter == null) {
        file = new File(dir, localPath);
        if (file.exists()) {
          counter = 0;

          file.renameTo(new File(dir, subLocalPath + counter++ + ".png"));
          file = new File(dir, subLocalPath + counter++ + ".png");
          pathCounter.put(key, counter);
        }
      }
      else {
        file = new File(dir, subLocalPath + counter++ + ".png");
        if (file.exists()) {
          throw new IOException();
        }

        pathCounter.put(key, counter);
      }

      ImageIO.write(image, "png", file);
    }

    //System.out.print("duplicated: " + duplicateCount + "\n");
  }

  private final Map<String,Integer> pathCounter = new HashMap<String, Integer>();

  private static String convertToHex(byte[] data) {
    StringBuilder buf = new StringBuilder();
    for (byte aData : data) {
      int halfbyte = (aData >>> 4) & 0x0F;
      int two_halfs = 0;
      do {
        if ((0 <= halfbyte) && (halfbyte <= 9)) {
          buf.append((char)('0' + halfbyte));
        }
        else {
          buf.append((char)('a' + (halfbyte - 10)));
        }
        halfbyte = aData & 0x0F;
      }
      while (two_halfs++ < 1);
    }
    return buf.toString();
  }
}