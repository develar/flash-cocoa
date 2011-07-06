package cocoa {
import flash.display.InteractiveObject;

public interface InteractiveRendererManager extends RendererManager {
  function get mouseSelectionMode():int;

  function setSelecting(itemIndex:int, value:Boolean):void;
  function setSelected(itemIndex:int, value:Boolean):void;

  function getItemIndexAt(x:Number):int;

  function getItemInteractiveObject(itemIndex:int):InteractiveObject;
}
}
