package cocoa.colorPicker {
import flash.events.Event;

public class ColorEvent extends Event {
  public static const SET_COLOR:String = "setColor";

  public function ColorEvent(color:Number) {
    super(SET_COLOR, true);

    _color = color;
  }

  private var _color:Number;
  public function get color():Number {
    return _color;
  }
}
}