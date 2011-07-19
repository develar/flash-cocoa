package cocoa.renderer {
import cocoa.Insets;
import cocoa.ItemMouseSelectionMode;
import cocoa.ListSelectionModel;
import cocoa.text.TextFormat;

import flash.display.InteractiveObject;

[Abstract]
public class InteractiveTextRendererManager extends TextRendererManager implements InteractiveRendererManager {
  public function InteractiveTextRendererManager(textFormat:TextFormat = null, textInsets:Insets = null) {
    super(textFormat, textInsets);
  }

  protected var _fixedRendererDimension:Number;
  public function set fixedRendererDimension(value:Number):void {
    _fixedRendererDimension = value;
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

  public function setSelected(itemIndex:int, relatedIndex:int, value:Boolean):void {
  }

  public function getItemIndexAt(x:Number, y:Number):int {
    throw new Error("abstract");
  }

  public function getItemInteractiveObject(itemIndex:int):InteractiveObject {
    return null;
  }

  protected var _selectionModel:ListSelectionModel;
  public function set selectionModel(value:ListSelectionModel):void {
    _selectionModel = value;
  }
}
}
