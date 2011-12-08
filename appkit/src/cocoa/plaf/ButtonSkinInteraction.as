package cocoa.plaf {
import flash.events.MouseEvent;

public interface ButtonSkinInteraction {
  function mouseOverHandler(event:MouseEvent):void;

  function mouseOutHandler(event:MouseEvent):void;

  function mouseUpHandler(event:MouseEvent):void;

  function delegateInteraction():void;

  function mouseDownHandler(event:MouseEvent):void;

  function get enabled():Boolean;
}
}