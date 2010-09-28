package cocoa {
import cocoa.text.EditableTextView;
import cocoa.text.TextInputUIModel;
import cocoa.text.TextUIModel;

import flash.utils.Dictionary;

import spark.events.TextOperationEvent;

use namespace ui;

public class TextInput extends AbstractComponent implements Control {
  protected static const _skinParts:Dictionary = new Dictionary();
  _skinParts.textDisplay = 0;
  override protected function get skinParts():Dictionary {
    return _skinParts;
  }

  ui var textDisplay:EditableTextView;

  protected var _action:Function;
  public function set action(value:Function):void {
    _action = value;
  }

  public function get objectValue():Object {
    return _text;
  }

  public function set objectValue(value:Object):void {
    text = String(value);
  }

  private var _text:String;
  public function get text():String {
    return textDisplay == null ? _text : textDisplay.text;
  }

  private var _uiModel:TextUIModel;
  public function set uiModel(value:TextUIModel):void {
    _uiModel = value;
    if (textDisplay != null) {
      textDisplay.uiModel = _uiModel;
    }
  }

  public function set text(value:String):void {
    if (value != _text) {
      _text = value;
      if (textDisplay != null) {
        textDisplay.text = _text;
      }
    }
  }

  ui function textDisplayAdded():void {
    if (_text != null) {
      textDisplay.text = _text;
    }

    textDisplay.uiModel = _uiModel == null ? createDefaultUIModel() : _uiModel;
    textDisplay.addEventListener(TextOperationEvent.CHANGE, inputChangeHandler);
  }

  protected function createDefaultUIModel():TextUIModel {
    return TextInputUIModel.getDefault();
  }

  private function inputChangeHandler(event:TextOperationEvent):void {
    if (_action != null) {
      _action();
    }
    //_text property must be actual because set text checks (value != _text)
    _text = textDisplay.text;
  }

  override protected function get primaryLaFKey():String {
    return "TextInput";
  }
}
}