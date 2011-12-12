package cocoa.message {
import cocoa.AbstractSkinnableView;
import cocoa.text.EditableTextView;
import cocoa.ui;

import flash.utils.Dictionary;

use namespace ui;

public class ApplicationNotification extends AbstractSkinnableView {
  public function ApplicationNotification() {
    super();

    _skinClass = ApplicationNotificationSkin;
  }

  private static const _skinParts:Dictionary = new Dictionary();
  _skinParts.textDisplay = 0;
  override protected function get skinParts():Dictionary {
    return _skinParts;
  }

  ui var textDisplay:EditableTextView;

  private var _text:String;
  public function set text(value:String):void {
    if (value != _text) {
      _text = value;
      if (textDisplay != null) {
        textDisplay.text = _text;
      }
    }
  }

  ui function textDisplayAdded():void {
    textDisplay.text = _text;
  }
}
}