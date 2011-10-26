package cocoa.util {
public final class ColorUtil {
  /**
   * argb to alpha 0.0-1.0
   */
  public static function argbToFloatAlpha(argb:uint):uint {
    return ((argb >>> 24) & 0xff) / 0xff;
  }

  public static function argbToRGB(argb:uint):uint {
    return argb & 0x00ffffff;
  }

  public static function rgbToARGB(rgb:uint, floatAlpha:Number = 1):uint {
    return ((uint(floatAlpha * 0xff) << 24) | rgb);
  }
}
}