package cocoa {
import flash.display.Graphics;

public interface Icon {
  function get iconWidth():Number;

  function get iconHeight():Number;

  function draw(view:View, g:Graphics, x:Number, y:Number):void;
}
}