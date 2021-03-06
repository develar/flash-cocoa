package cocoa {
public class Insets {
  public static const EMPTY:Insets = new Insets();

  public var left:Number;
  public var top:Number;
  public var right:Number;
  public var bottom:Number;

  public function Insets(left:Number = 0, top:Number = 0, right:Number = 0, bottom:Number = 0) {
    this.left = left;
    this.top = top;
    this.right = right;
    this.bottom = bottom;

    _width = left + right;
    _height = top + bottom;
  }

  private var _width:Number;
  public final function get width():Number {
    return _width;
  }

  private var _height:Number;
  public final function get height():Number {
    return _height;
  }
}
}