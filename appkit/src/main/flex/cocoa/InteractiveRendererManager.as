package cocoa {
public interface InteractiveRendererManager extends RendererManager {
  function setSelecting(itemIndex:int, value:Boolean):void;
  function setSelected(itemIndex:int, value:Boolean):void;
}
}
