import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.color.ColorSpace;
import java.awt.image.*;
import java.io.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

public class Decoder {
  private final Set<String> duplicateGuard = new HashSet<String>();

  private final ByteBuffer data;
  public int numOfImages = 0;

  private final short fileCount;
  private final int tagCount;
  private final int tagDescriptorsOffset;
  private final int tagNamesOffset;
  private final int fileDescriptorsOffset;
  private final int fileDataSectionOffset;

  private File outputDir;
  public final CharSequence[] names;
  public int[] tags = new int[8];
  private final int numOfTags = 0;

  @SuppressWarnings("ResultOfMethodCallIgnored")
  public Decoder(String filepath, String output) throws IOException {
    outputDir = new File(output);
    if (outputDir.exists()) {
      outputDir.renameTo(new File(output + "_old_" + Math.random() * 100));
    }

    outputDir = new File(output);
    outputDir.mkdirs();

    final File file = new File(filepath);
    data = ByteBuffer.allocate((int)file.length());
    data.order(ByteOrder.LITTLE_ENDIAN);
    final FileInputStream inputStream = new FileInputStream(file);
    final FileChannel channel = inputStream.getChannel();
    try {
      while (data.hasRemaining()) {
        channel.read(data);
      }
      data.clear();
    }
    finally {
      inputStream.close();
    }

    fileCount = data.getShort();
    // skip maxDepth
    data.position(data.position() + 2);
    tagCount = data.getInt();
    tagDescriptorsOffset = data.getInt();
    tagNamesOffset = data.getInt();
    fileDescriptorsOffset = data.getInt();
    fileDataSectionOffset = data.getInt();

    // 1-based
    names = new CharSequence[tagCount + 1];
  }

  public void decode() throws IOException {
    readTagDescriptors();

    final ComponentColorModel colorModel = new ComponentColorModel(ColorSpace.getInstance(ColorSpace.CS_sRGB), true, false, Transparency.TRANSLUCENT, DataBuffer.TYPE_BYTE);
    final int[] bandOffsets = {2, 1, 0, 3};

    for (int i = 0; i < fileCount; i++) {
      data.position(fileDescriptorsOffset + ((4 + 8) * i));
      final int fileDataOffset = data.getInt();
      final int[] tags = new int[8];
      for (int j = 0; j < 8; j++) {
        tags[j] = data.get() & 0xff;
      }

      data.position(fileDataSectionOffset + fileDataOffset);
      final int artRows = data.getShort();
      final int artColumns = data.getShort();
      // skip unknown
      data.position(data.position() + 28);
      
      final int[] subimageOffsets = readNumericArray(9, false);
      final int[] subimageWidths = readNumericArray(9, true);
      final int[] subimageHeights = readNumericArray(9, true);

      StringBuilder filename = new StringBuilder();
      for (int y : tags) {
        if (y == 0) {
          continue;
        }

        filename.append('/').append(names[y]);
      }

      final byte[] bytes = data.array();
      final int imageCount = artRows * artColumns;
      for (int subImageIndex = 0; subImageIndex < imageCount; subImageIndex++) {
        final int w = subimageWidths[subImageIndex];
        final int h = subimageHeights[subImageIndex];
        if (w <= 0 || h <= 0) {
          continue;
        }

        final byte[] bgra = new byte[w * h * 4];
        System.arraycopy(bytes, fileDataSectionOffset + fileDataOffset + subimageOffsets[subImageIndex], bgra, 0, bgra.length);
        BufferedImage image = new BufferedImage(colorModel, (WritableRaster)Raster.createRaster(new PixelInterleavedSampleModel(DataBuffer.TYPE_BYTE, w, h, 4, w * 4, bandOffsets), new DataBufferByte(bgra, w * h), null), false, null);
        File file = new File(outputDir, filename.substring(1) + '_' + subImageIndex + ".png");
        //noinspection ResultOfMethodCallIgnored
        file.getParentFile().mkdirs();
        ImageIO.write(image, "png", file);
      }
    }
  }

  private int[] readNumericArray(final int length, final boolean isShort) {
    final int[] r = new int[length];
    for (int i = 0; i < length; i++) {
      r[i] = isShort ? data.getShort() : data.getInt();
    }
    return r;
  }

  private void readTagDescriptors() throws IOException {
    int tagDescriptorOffset = tagDescriptorsOffset;
    final byte[] bytes = data.array();
    final Charset utf8 = Charset.forName("utf-8");
    for (int i = 0; i < tagCount; i++) {
      final int dNameOffset = data.getInt(tagDescriptorOffset);
      tagDescriptorOffset += 4;
      final int tagIndex = data.get(tagDescriptorOffset) & 0xff;
      tagDescriptorOffset += 4;

      final int nameOffset = tagNamesOffset + dNameOffset;
      int stringLength = 0;
      while (bytes[nameOffset + stringLength] != 0) {
        stringLength++;
      }

      data.mark();
      data.position(nameOffset);
      data.limit(nameOffset + stringLength);

      names[tagIndex] = utf8.decode(data);
      
      data.reset();
      data.limit(data.capacity());
    }
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