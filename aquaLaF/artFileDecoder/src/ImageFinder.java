import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class ImageFinder {
  public static void main(String[] args) throws IOException {
    //build(new File("/Users/develar/dc"));

    req(new File("/Users/develar/test/artFiles/scrollbars"));
  }

  private static void req(File root) throws IOException {
    for (String name : root.list()) {
      if (name.indexOf('.') == -1) {
        File file = new File(root, name);
        if (file.isDirectory()) {
          build(file);
          req(file);
        }
      }
    }
  }

  private static void build(File root) throws IOException {
    for (String name : root.list()) {
      if (!name.endsWith(".png")) {
        continue;
      }

      BufferedImage image = ImageIO.read(new File(root, name));
      //if (image.getHeight() < 15) {
      //   continue;
      //}

      int alpha = image.getRGB(image.getWidth() / 2, image.getHeight() / 2) >>> 24;
      if (alpha == 58) {
        System.out.println(root + "/" + name + " ");
      }

      //for (int pixel : image.getRGB(0, 0, image.getWidth(), image.getHeight(), null, 0, image.getWidth())) {
      //  Color color = new Color(pixel, true);
      //  //if (color.getRed() == 255 && color.getAlpha() == 202) {
      //  if (color.getAlpha() == 160) {
      //    System.out.println(name);
      //    break;
      //  }
    }
  }
}