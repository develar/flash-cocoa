package cocoa.util {
import flash.display.DisplayObject;
import flash.geom.Point;

public final class SharedPoint {
  public static var point:Point = new Point(0, 0);

  public static function get emptyPoint():Point {
    var p:Point = point;
    p.x = 0;
    p.y = 0;
    return p;
  }

  public static function createPoint(o:DisplayObject):Point {
    var p:Point = point;
    p.x = o.x;
    p.y = o.y;
    return p;
  }
}
}
