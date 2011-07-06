package cocoa {
import cocoa.text.TextFormat;

import flash.display.InteractiveObject;

public class InteractiveTextRendererManager extends TextRendererManager implements InteractiveRendererManager {
  public function InteractiveTextRendererManager(textFormat:TextFormat, textInsets:Insets) {
    super(textFormat, textInsets);
  }

  private var _mouseSelectionMode:int = ItemMouseSelectionMode.CLICK;
  public function get mouseSelectionMode():int {
    return _mouseSelectionMode;
  }
  public function set mouseSelectionMode(value:int):void {
    if (value != _mouseSelectionMode) {
      _mouseSelectionMode = value;
    }
  }

  public function setSelecting(itemIndex:int, value:Boolean):void {
  }

  public function setSelected(itemIndex:int, value:Boolean):void {
  }

  public function getItemIndexAt(x:Number):int {
    return 0;
  }

  public function getItemInteractiveObject(itemIndex:int):InteractiveObject {
    return null;
  }
}
}
