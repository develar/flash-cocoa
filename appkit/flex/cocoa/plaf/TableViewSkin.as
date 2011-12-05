package cocoa.plaf {
import flash.display.Sprite;

public interface TableViewSkin extends Skin {
  function get bodyHitArea():Sprite;

  function getColumnIndexAt(x:Number):int;

  function getRowIndexAt(y:Number):int;
}
}
