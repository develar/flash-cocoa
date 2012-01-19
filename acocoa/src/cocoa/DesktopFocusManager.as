package cocoa {
import flash.display.Stage;
import flash.events.Event;

public class DesktopFocusManager extends FocusManagerImpl {
  override public function init(stage:Stage):void {
    super.init(stage);

    stage.nativeWindow.addEventListener(Event.ACTIVATE, windowActivateHandler);
  }

  protected function windowActivateHandler(event:Event):void {
  }
}
}
