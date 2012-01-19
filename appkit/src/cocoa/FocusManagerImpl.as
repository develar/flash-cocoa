package cocoa {
import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.events.FocusEvent;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldType;

public class FocusManagerImpl implements FocusManager {
  protected var lastFocus:Focusable;

  public function setFocus(o:Focusable):void {
    if (lastFocus != o) {
      lastFocus = o;
      o.focusObject.stage.focus = o.focusObject;
    }
  }

  public function init(stage:Stage):void {
    stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler);
    stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler);

    stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);

    stage.stageFocusRect = false;
  }

  protected static function getTopLevelFocusTarget(o:InteractiveObject):Focusable {
    while (true) {
      if (o is Focusable) {
        return Focusable(o);
      }

      if ((o = o.parent) == null) {
        break;
      }
    }

    return null;
  }

  protected static function mouseFocusChangeHandler(event:FocusEvent):void {
    if (event.isDefaultPrevented()) {
      return;
    }

    if (event.relatedObject == null && event.isRelatedObjectInaccessible) {
      // lost focus to a control in different sandbox.
      return;
    }

    var textField:TextField = event.relatedObject as TextField;
    if (textField != null && (textField.type == TextFieldType.INPUT || textField.selectable)) {
      return; // pass it on
    }

    event.preventDefault();
  }

  protected function mouseDownHandler(event:MouseEvent):void {
    var target:InteractiveObject = InteractiveObject(event.target);
    var newFocus:Focusable = getTopLevelFocusTarget(target);
    if (newFocus != lastFocus && newFocus != null) {
      lastFocus = newFocus;
      target.stage.focus = newFocus.focusObject;
    }
  }

  protected function keyFocusChangeHandler(event:FocusEvent):void {
  }
}
}
