package cocoa.util {
public final class Vectors {
  public static function sortDecreasing(x:int, y:int):Number {
    return y - x;
  }

  public static function sortAscending(x:int, y:int):Number {
    return x - y;
  }

  public static function isEmpty(v:Vector.<int>):Boolean {
    return v == null || v.length == 0;
  }
}
}
