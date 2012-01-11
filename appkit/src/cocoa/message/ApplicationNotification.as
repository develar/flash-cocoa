package cocoa.message {
import cocoa.AbstractSkinnableView;
import cocoa.text.EditableTextView;
import cocoa.ui;

use namespace ui;

public class ApplicationNotification extends AbstractSkinnableView {
  public function ApplicationNotification() {
    super();

    _skinClass = ApplicationNotificationSkin;
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