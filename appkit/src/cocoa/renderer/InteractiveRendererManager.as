package cocoa.renderer {
import cocoa.ListSelectionModel;
import cocoa.layout.ExplicitDimensionProvider;

import flash.display.InteractiveObject;

public interface InteractiveRendererManager extends RendererManager {
  function get mouseSelectionMode():int;

  function setSelecting(itemIndex:int, value:Boolean):void;
  function setSelected(itemIndex:int, relatedIndex:int, value:Boolean):void;

  function getItemIndexAt(x:Number, y:Number):int;

  function getItemInteractiveObject(itemIndex:int):InteractiveObject;

  function set selectionModel(selectionModel:ListSelectionModel):void;

  function set fixedRendererDimension(value:ExplicitDimensionProvider):void;
}
}