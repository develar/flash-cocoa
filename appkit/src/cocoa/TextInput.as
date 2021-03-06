package cocoa {
import cocoa.text.EditableTextView;
import cocoa.text.TextInputUIModel;
import cocoa.text.TextUIModel;

import flash.display.InteractiveObject;

import spark.events.TextOperationEvent;

use namespace ui;

public class TextInput extends AbstractControl implements Focusable {
  ui var textDisplay:EditableTextView;

  override public function set action(value:Function):void {
    if (textDisplay != null) {
      if (value != null) {
        if (_action == null) {
          textDisplay.addEventListener(TextOperationEvent.CHANGE, inputChangeHandler);
        }
      }
      else if (_action != null) {
        textDisplay.removeEventListener(TextOperationEvent.CHANGE, inputChangeHandler);
      }
    }

    super.action = value;
  }

  override public function get objectValue():Object {
    return _text;
  }

  override public function set objectValue(value:Object):void {
    text = value as String;
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
    if (value != text) {
      if (textDisplay != null) {
        textDisplay.text = _text;
      }
      else {
        _text = value;
      }
    }
  }

  ui function textDisplayAdded():void {
    if (_text != null) {
      textDisplay.text = _text;
      _text = null;
    }

    textDisplay.uiModel = _uiModel == null ? createDefaultUIModel() : _uiModel;
    if (_action != null) {
      textDisplay.addEventListener(TextOperationEvent.CHANGE, inputChangeHandler);
    }
  }

  protected function createDefaultUIModel():TextUIModel {
    return TextInputUIModel.getDefault();
  }

  private function inputChangeHandler(event:TextOperationEvent):void {
    callUserInitiatedActionHandler();
  }

  override protected function get primaryLaFKey():String {
    return "TextInput";
  }

  public function get focusObject():InteractiveObject {
    return Focusable(skin).focusObject;
  }
}
}