package cocoa.util {
import flash.geom.Rectangle;

public final class RatioUtil {
  public static function heightToWidth(rectangle:Rectangle):Number {
    return rectangle.height / rectangle.width;
  }

  public static function widthToHeight(rectangle:Rectangle):Number {
    return rectangle.width / rectangle.height;
  }

  public static function scaleWidth(rectangle:Rectangle, height:Number):Rectangle {
    var rec:Rectangle = rectangle.clone();
    rec.width = height * widthToHeight(rectangle);
    rec.height = height;
    return rec;
  }

  public static function scaleHeight(rectangle:Rectangle, width:Number):Rectangle {
    var rec:Rectangle = rectangle.clone();
    rec.width = width;
    rec.height = width * heightToWidth(rectangle);
    return rec;
  }

  public static function scaleToFit(source:Rectangle, bounds:Rectangle):Rectangle {
    var scaled:Rectangle = scaleHeight(source, bounds.width);
    if (scaled.height > bounds.height) {
      scaled = scaleWidth(source, bounds.height);
    }
    return scaled;
  }

  public static function scaleToFill(source:Rectangle, bounds:Rectangle):Rectangle {
    var scaled:Rectangle = scaleHeight(source, bounds.width);
    if (scaled.height < bounds.height) {
      scaled = scaleWidth(source, bounds.height);
    }

    return scaled;
  }
}
}