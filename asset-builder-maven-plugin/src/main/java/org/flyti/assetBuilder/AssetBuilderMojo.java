package org.flyti.assetBuilder;

import org.apache.maven.artifact.Artifact;
import org.apache.maven.model.Resource;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.project.MavenProject;
import org.yaml.snakeyaml.TypeDescription;
import org.yaml.snakeyaml.Yaml;
import org.yaml.snakeyaml.constructor.Constructor;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.*;
import java.util.*;
import java.util.List;

/**
 * @goal generate
 * @phase generate-sources
 * @requiresDependencyResolution compile
 * <p/>
 * При поиске мы формируем имя согласно key + "." + имя состояния. пока что считаем что список состояний равен "off, on".
 */
public class AssetBuilderMojo extends AbstractMojo {
  /**
   * @parameter expression="${asset.builder.skip}"
   */
  @SuppressWarnings({"UnusedDeclaration"})
  private boolean skip;

  /**
   * @parameter expression="${project}"
   * @required
   * @readonly
   */
  @SuppressWarnings({"UnusedDeclaration"})
  private MavenProject project;

  /**
   * @parameter default-value="${project.build.directory}/assets"
   */
  @SuppressWarnings({"UnusedDeclaration"})
  private File output;

  /**
   * @parameter default-value="src/main/resources/assets.yml"
   */
  @SuppressWarnings({"UnusedDeclaration"})
  private File descriptor;

  private List<File> sources;

  /**
   * @parameter
   */
  @SuppressWarnings({"UnusedDeclaration"})
  private File[] inputs;

  private AssetOutputStream out;

  @Override
  public void execute() throws MojoExecutionException, MojoFailureException {
    if (skip) {
      getLog().warn("Skipping generate assets");
      return;
    }

    if (!descriptor.exists()) {
      getLog().warn("Can't find assets descriptor");
      return;
    }

    try {
      setUpImageDirectories();
    }
    catch (Exception e) {
      throw new MojoExecutionException("Can't set up images source directories", e);
    }

    doExecute();
  }

  private void doExecute() throws MojoExecutionException {
    final Constructor constructor = new Constructor(AssetSet.class);
    final TypeDescription borderDescription = new TypeDescription(AssetSet.class);
    borderDescription.putListPropertyType("borders", Border.class);
    constructor.addTypeDescription(borderDescription);
    final Yaml yaml = new Yaml(constructor);
    final AssetSet assetSet;
    try {
      assetSet = (AssetSet) yaml.load(new BufferedInputStream(new FileInputStream(descriptor)));
    }
    catch (FileNotFoundException e) {
       throw new MojoExecutionException("Can't read descriptor", e);
    }

    //noinspection ResultOfMethodCallIgnored
    output.getParentFile().mkdirs();

    try {
      out = new AssetOutputStream(new BufferedOutputStream(new FileOutputStream(output)));
      buildBorders(assetSet.borders);

      new IconPackager().pack(sources, out);

      out.flush();
    }
    catch (IOException e) {
      throw new MojoExecutionException("Can't write to output file", e);
    }
    finally {
      if (out != null) {
        try {
          out.close();
        }
        catch (IOException ignored) {
        }
      }
    }
  }

  private void setUpImageDirectories() throws IOException, ClassNotFoundException {
    if (inputs != null) {
      sources = Arrays.asList(inputs);
      return;
    }

    sources = new ArrayList<File>();
    //noinspection unchecked
    for (Resource resource : project.getResources()) {
      sources.add(new File(resource.getDirectory()));
    }

    final Map<String, String> projectResourceDirectoryMap;
    final File projectResourceDirectoryCache = new File(project.getBuild().getDirectory(), "projectResourceDirectoryMap");
    if (projectResourceDirectoryCache.exists()) {
      //noinspection unchecked
      projectResourceDirectoryMap = (Map<String, String>) new ObjectInputStream(new FileInputStream(projectResourceDirectoryCache)).readObject();
    }
    else {
      projectResourceDirectoryMap = new HashMap<String, String>();
    }

    Map<String, MavenProject> projectReferences = project.getProjectReferences();
    for (Artifact artifact : project.getArtifacts()) {
      if ("swc".equals(artifact.getType())) {
        final String referenceProjectId = getProjectReferenceId(artifact.getGroupId(), artifact.getArtifactId(), artifact.getVersion());
        final File referenceResourceDirectory;
        if (projectResourceDirectoryMap.containsKey(referenceProjectId)) {
          referenceResourceDirectory = new File(projectResourceDirectoryMap.get(referenceProjectId));
          if (!referenceResourceDirectory.exists()) {
            projectResourceDirectoryMap.remove(referenceProjectId);
            continue;
          }
        }
        else {
          MavenProject referenceProject = projectReferences.get(referenceProjectId);
          if (referenceProject == null) {
            continue; // пока что только берем из resource directories, но swc не парсим
          }
          referenceResourceDirectory = new File(referenceProject.getResources().get(0).getDirectory());
          if (referenceResourceDirectory.exists()) {
            projectResourceDirectoryMap.put(referenceProjectId, referenceResourceDirectory.getAbsolutePath());
          }
          else {
            continue;
          }
        }

        sources.add(referenceResourceDirectory);
      }
    }

    if (!projectResourceDirectoryMap.isEmpty()) {
      //noinspection ResultOfMethodCallIgnored
      projectResourceDirectoryCache.getParentFile().mkdirs();
      new ObjectOutputStream(new FileOutputStream(projectResourceDirectoryCache)).writeObject(projectResourceDirectoryMap);
    }
  }

  private static String getProjectReferenceId(String groupId, String artifactId, String version) {
    StringBuilder buffer = new StringBuilder(128);
    buffer.append(groupId).append(':').append(artifactId).append(':').append(version);
    return buffer.toString();
  }

  private void buildBorders(List<Border> borders) throws IOException, MojoExecutionException {
    out.writeByte(borders.size());

    ImageRetriever imageRetriever = new ImageRetriever(sources);
    CompoundImageReader compoundImageReader = null;

    for (Border border : borders) {
      final String key = border.subkey == null ? border.key : (border.subkey + "." + border.key);
      out.writeUTF(border.key.indexOf('.') == -1 ? (key + ".b") : key);

      if (border.type == BorderType.One || border.type == BorderType.Scale9Edge) {
        out.writeByte(border.type.ordinal());
        final BufferedImage sourceImage;
        if (border.source == null) {
          sourceImage = imageRetriever.getImage(key);
        }
        else {
          if (compoundImageReader == null) {
            File compoundImageFile = border.source.file;
            if (compoundImageFile == null) {
              compoundImageFile = sources.get(0);
            }
            else if (!compoundImageFile.isAbsolute()) {
              compoundImageFile = new File(descriptor.getParent(), compoundImageFile.getPath());
            }
            compoundImageReader = new CompoundImageReader(compoundImageFile);
          }

          sourceImage = compoundImageReader.getImage(border.source.rectangle);
        }

        switch (border.type) {
          case One:
            out.write(sourceImage);
            break;

          case Scale9Edge:
            out.write(slice9(sourceImage, border.minTop));
            break;
        }
      }
      else {
        final BufferedImage[] sourceImages = border.appleResource == null ? imageRetriever.getImages(key) : imageRetriever.getImagesFromAppleResources(border.appleResource);
        if (border.type == BorderType.Scale3EdgeH) {
          if (border.appleResource == null) {
            if ((sourceImages[0].getWidth() == sourceImages[1].getWidth())) {
              out.writeByte(border.type.ordinal());
              // мы рассчитываем slice size для изображения on, а не off состояния, так как зачастую именно оно дает наиболее полный slice size,
              // иначе для off оно будет маленьким и его не хватит для on (на примере Fluent PopUp Button в on будет обрезана стрелка) — мы то считаем один раз для всех состояний.
              // Такая политика — расчет по одному изображения для всех состояний на 100% работает для Aqua UI, а во Fluent UI есть вот такие заморочки.
              out.write(slice3H(sourceImages, SliceCalculator.calculate(sourceImages[1])));
            }
            else { // see note in Scale3EdgeHBitmapBorderWithSmartFrameInsets, only for Fluent
              out.writeByte(BorderType.Scale3EdgeHWithSmartFrameInsets.ordinal());
              out.write(slice3H(sourceImages));
            }
          }
          else {
            out.writeByte(border.type.ordinal());
            out.write(joinButtonAppleResources(sourceImages));
          }
        }
        else {
          out.writeByte(border.type.ordinal());
          out.write(sourceImages);
        }
      }

      lazyWriteInsets(border.contentInsets, true);
      lazyWriteInsets(border.frameInsets, false);
    }
  }

  private BufferedImage[] joinButtonAppleResources(BufferedImage[] sourceImages) throws IOException, MojoExecutionException {
    final int n = sourceImages.length;
    BufferedImage[] images = new BufferedImage[n - (n / 3)];
    for (int i = 0, bitmapIndex = 0; i < n; i += 3) {
      BufferedImage left = sourceImages[i];
      BufferedImage center = sourceImages[i + 1];

      if (center.getWidth() != 1) {
        throw new MojoExecutionException("The width of the center must be 1px");
      }

      final int leftWidth = left.getWidth();
      final int height = left.getHeight();

      BufferedImage leftAndFill = new BufferedImage(leftWidth + 1, height, getAppropriateBufferedImageType(left));
      // с setRect были проблемы с colorSpace
      leftAndFill.setRGB(0, 0, leftWidth, height, imageToRGB(left), 0, leftWidth);
      leftAndFill.setRGB(leftWidth, 0, 1, height, imageToRGB(center), 0, 1);

      images[bitmapIndex++] = leftAndFill;
      images[bitmapIndex++] = sourceImages[i + 2];
    }

    return images;
  }

  private int[] imageToRGB(BufferedImage image) {
    return image.getRGB(0, 0, image.getWidth(), image.getHeight(), null, 0, image.getWidth());
  }

  private int getAppropriateBufferedImageType(BufferedImage original) {
    if (original.getType() == BufferedImage.TYPE_CUSTOM) {
      return original.getTransparency() == Transparency.TRANSLUCENT ? BufferedImage.TYPE_INT_ARGB : BufferedImage.TYPE_INT_RGB;
    }
    else {
      return original.getType();
    }
  }

  private BufferedImage[] slice3H(BufferedImage[] sourceImages, Insets sliceSize) {
    BufferedImage[] images = new BufferedImage[sourceImages.length * 2];
    final int frameHeight = sourceImages[0].getHeight();
    final int rightImageX = sourceImages[0].getWidth() - sliceSize.right;
    int imageIndex = 0;
    for (BufferedImage sourceImage : sourceImages) {
      images[imageIndex++] = sourceImage.getSubimage(0, 0, sliceSize.left + 1, frameHeight);
      images[imageIndex++] = sourceImage.getSubimage(rightImageX, 0, sliceSize.right, frameHeight);
    }

    return images;
  }

  private BufferedImage[] slice3H(BufferedImage[] sourceImages) {
    BufferedImage[] images = new BufferedImage[sourceImages.length * 2];
    int imageIndex = 0;
    for (BufferedImage sourceImage : sourceImages) {
      Insets sliceSize = SliceCalculator.calculate(sourceImage);
      images[imageIndex++] = sourceImage.getSubimage(0, 0, sliceSize.left + 1, sourceImage.getHeight());
      images[imageIndex++] = sourceImage.getSubimage(sourceImage.getWidth() - sliceSize.right, 0, sliceSize.right, sourceImage.getHeight());
    }

    return images;
  }

  private BufferedImage[] slice9(BufferedImage sourceImage, int minTop) {
    BufferedImage[] images = new BufferedImage[4];
    Rectangle frameRectangle = ImageCropper.findNonTransparentBounds(sourceImage);
    Insets sliceSize = SliceCalculator.calculate(sourceImage, frameRectangle, true, true, minTop);
    if (frameRectangle == null) {
      frameRectangle = sourceImage.getRaster().getBounds();
    }

    final int topHeight = sliceSize.top + 1;
    images[0] = sourceImage.getSubimage(frameRectangle.x, frameRectangle.y, sliceSize.left + 1, topHeight);
    final int rightX = frameRectangle.x + frameRectangle.width - sliceSize.right;
    images[1] = sourceImage.getSubimage(rightX, frameRectangle.y, sliceSize.right, topHeight);
    final int y = frameRectangle.y + frameRectangle.height - sliceSize.bottom;
    images[2] = sourceImage.getSubimage(frameRectangle.x, y, sliceSize.left + 1, sliceSize.bottom);
    images[3] = sourceImage.getSubimage(rightX, y, sliceSize.right, sliceSize.bottom);

    dump(images);
    return images;
  }

  @SuppressWarnings({"UnusedDeclaration"})
  private static void dump(BufferedImage[] images) {
    try {
      for (int i = 0, imagesLength = images.length; i < imagesLength; i++) {
        ImageIO.write(images[i], "png", new BufferedOutputStream(new FileOutputStream("/Users/develar/t" + i + ".png")));
      }
    }
    catch (IOException e) {
      e.printStackTrace();
    }
  }

  private void lazyWriteInsets(Insets insets, boolean isContent) throws IOException {
    if (insets == null) {
      out.writeByte(0);
    }
    else {
      out.writeByte(1);

      if (isContent) {
        out.writeByte(insets.truncatedTailMargin);
      }

      out.writeByte(insets.left);
      out.writeByte(insets.top);
      out.writeByte(insets.right);
      out.writeByte(insets.bottom);
    }
  }

  public static void main(String[] args) {
    if (args.length != 3) {
      throw new IllegalArgumentException("Usage: AssetBuilderMojo <descriptorFile> <outputFile> <source1,source2,source3>");
    }
    String descriptorFile = args[0];
    String outputFile = args[1];
    String sourceFiles = args[2];

    List<File> sources = new ArrayList<File>();
    StringTokenizer t = new StringTokenizer(sourceFiles, ",");
    while (t.hasMoreTokens()) {
      sources.add(new File(t.nextToken()));
    }

    AssetBuilderMojo mojo = new AssetBuilderMojo();
    mojo.descriptor = new File(descriptorFile);
    mojo.output = new File(outputFile);
    mojo.sources = sources;
    try {
      mojo.doExecute();
    } catch (MojoExecutionException e) {
      throw new RuntimeException(e);
    }
  }
}