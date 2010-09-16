package cocoa.plaf.basic.scrollbar {
import cocoa.Border;
import cocoa.FlexButton;

import flash.events.Event;
import flash.events.MouseEvent;

public final class TrackOrThumbButton extends FlexButton {
  override public function set border(value:Border):void {
    super.border = value;

    minHeight = _border.layoutHeight;
    minWidth = _border.layoutWidth;
  }

  override protected function addHandlers():void {
    addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
    addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
    addEventListener(MouseEvent.CLICK, mouseEventHandler);
  }

  override protected function mouseEventHandler(event:Event):void {
    var mouseEvent:MouseEvent = MouseEvent(event);
    if (!(mouseEvent.localX < 0 || mouseEvent.localY < 0 || mouseEvent.localX > width || mouseEvent.localY > height)) {
      super.mouseEventHandler(event);
    }
  }

  override public function invalidateSkinState():void {
  }
}
}