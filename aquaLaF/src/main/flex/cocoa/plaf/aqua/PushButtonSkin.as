package cocoa.plaf.aqua {
import cocoa.CellState;
import cocoa.border.MultipleBorder;
import cocoa.plaf.basic.PushButtonSkin;

import flash.events.MouseEvent;

public class PushButtonSkin extends cocoa.plaf.basic.PushButtonSkin {
  override protected function updateDisplayList(w:Number, h:Number):void {
    MultipleBorder(border).stateIndex = enabled ? (myComponent.state == CellState.ON ? 1 : 0) : 2;

    super.updateDisplayList(w, h);
  }

  override public function mouseOverHandler(event:MouseEvent):void {
    MultipleBorder(border).stateIndex = myComponent.state == CellState.ON ? 0 : 1;
    super.mouseOverHandler(event);
  }

  override public function mouseOutHandler(event:MouseEvent):void {
    MultipleBorder(border).stateIndex = myComponent.state == CellState.ON ? 1 : 0;
    super.mouseOverHandler(event);
  }

  override protected function mouseUp():void {
    super.mouseUp();

    MultipleBorder(border).stateIndex = 0;
  }
}
}