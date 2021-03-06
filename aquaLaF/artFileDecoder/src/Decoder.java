import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.color.ColorSpace;
import java.awt.image.*;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.FileChannel;
import java.nio.charset.Charset;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.*;
import java.util.List;

public class Decoder {
  private final ByteBuffer data;

  private final short fileCount;
  private final int tagCount;
  private final int tagDescriptorsOffset;
  private final int tagNamesOffset;
  private final int fileDescriptorsOffset;
  private final int fileDataSectionOffset;

  private File outputDir;
  private final CharSequence[] names;

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

    final MessageDigest md;
    try {
      md = MessageDigest.getInstance("SHA-512");
    }
    catch (NoSuchAlgorithmException e) {
      e.printStackTrace();
      return;
    }

    final ComponentColorModel colorModel = new ComponentColorModel(ColorSpace.getInstance(ColorSpace.CS_sRGB), true, false, Transparency.TRANSLUCENT, DataBuffer.TYPE_BYTE);
    final int[] bandOffsets = {2, 1, 0, 3};
    final Map<String, String> duplicateGuard = new HashMap<String, String>();
    final byte[] bytes = data.array();
    final int[] tags = new int[8];
    
    final List<String> symLinkCommand = new ArrayList<String>(4);
    symLinkCommand.add("ln");
    symLinkCommand.add("-s");
    symLinkCommand.add(null);
    symLinkCommand.add(null);

    for (int fileIndex = 0; fileIndex < fileCount; fileIndex++) {
      data.position(fileDescriptorsOffset + ((4 + 8) * fileIndex));
      final int fileDataOffset = data.getInt();
      int numOfTags = 8;
      for (int i = 0; i < 8; i++) {
        int tag = data.get() & 0xff;
        if (tag == 0) {
          numOfTags = i;
          break;
        }
        tags[i] = tag;
      }

      data.position(fileDataSectionOffset + fileDataOffset);
      final int artRows = data.getShort();
      final int artColumns = data.getShort();
      // skip unknown
      data.position(data.position() + 28);
      
      final int[] subimageOffsets = readNumericArray(9, false);
      final int[] subimageWidths = readNumericArray(9, true);
      final int[] subimageHeights = readNumericArray(9, true);

      assert numOfTags >= 2;
      final File dir;
      final int tagStartIndexForFilename;
      if (numOfTags == 2) {
        tagStartIndexForFilename = 1;
        dir = new File(outputDir, names[tags[0]].toString());
      }
      else {
        tagStartIndexForFilename = 2;
        dir = new File(outputDir, names[tags[0]] + "/" + names[tags[1]]);
      }

      boolean dirCreated = false;

      final int imageCount = artRows * artColumns;
      for (int subImageIndex = 0; subImageIndex < imageCount; subImageIndex++) {
        final int w = subimageWidths[subImageIndex];
        final int h = subimageHeights[subImageIndex];
        if (w <= 0 || h <= 0) {
          continue;
        }

        final int srcPos = fileDataSectionOffset + fileDataOffset + subimageOffsets[subImageIndex];
        final int srcLength = w * h * 4;

        md.update(bytes, srcPos, srcLength);
        md.update((byte)w);
        md.update((byte)h);
        final String digest = convertToHex(md.digest());
        md.reset();

        if (!dirCreated) {
          //noinspection ResultOfMethodCallIgnored
          dir.mkdirs();
          dirCreated = true;
        }

        final byte[] bgra = new byte[srcLength];
        // cannot pass bytes directly, offset in DataBufferByte is not working
        System.arraycopy(bytes, srcPos, bgra, 0, bgra.length);
        BufferedImage image = new BufferedImage(colorModel,
          (WritableRaster)Raster.createRaster(new PixelInterleavedSampleModel(DataBuffer.TYPE_BYTE, w, h, 4, w * 4, bandOffsets),
            new DataBufferByte(bgra, bgra.length), null), false, null);

        final StringBuilder outFilename = createOutpuFile(numOfTags, tags, tagStartIndexForFilename, imageCount > 0, subImageIndex);
        final String oldOutFilename = duplicateGuard.get(digest);
        if (oldOutFilename == null) {
          File file = new File(dir, outFilename.toString());
          duplicateGuard.put(digest, file.getPath());
          ImageIO.write(image, "png", file);
        }
        else {
          symLinkCommand.set(2, oldOutFilename);
          symLinkCommand.set(3, dir + "/" + outFilename);
          Process process = new ProcessBuilder(symLinkCommand).start();
          try {
            if (process.waitFor() != 0) {
              throw new IOException("Can't create symlink " + symLinkCommand.get(2) + " " + symLinkCommand.get(3));
            }
          }
          catch (InterruptedException e) {
            throw new IOException(e);
          }
        }
      }
    }
  }

  private StringBuilder createOutpuFile(int numOfTags, int[] tags, int tagStartIndexForFilename, boolean multiple, int subImageIndex) {
    final StringBuilder filenameBuilder = new StringBuilder();
    int i = tagStartIndexForFilename;
    while (true) {
      filenameBuilder.append(names[tags[i]]);
      if (++i == numOfTags) {
        break;
      }
      else {
        filenameBuilder.append('.');
      }
    }
    
    if (multiple) {
      filenameBuilder.append('-').append(subImageIndex);
    }

    return filenameBuilder.append(".png");
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

  private final char[] chars = new char[128];

  private String convertToHex(byte[] data) {
    int i = 0;
    char[] chars = this.chars;
    for (byte aData : data) {
      int halfbyte = (aData >>> 4) & 0x0F;
      int two_halfs = 0;
      do {
        chars[i++] = (0 <= halfbyte) && (halfbyte <= 9) ? (char)('0' + halfbyte) : (char)('a' + (halfbyte - 10));
        halfbyte = aData & 0x0f;
      }
      while (two_halfs++ < 1);
    }

    return new String(chars);
  }
}