package cocoa.plaf.aqua {
import cocoa.CellState;
import cocoa.border.StatefulBorder;
import cocoa.plaf.basic.PushButtonSkin;

import flash.events.MouseEvent;

public class PushButtonSkin extends cocoa.plaf.basic.PushButtonSkin {
  override protected function draw(w:Number, h:Number):void {
    StatefulBorder(border).stateIndex = enabled ? (myComponent.state == CellState.ON ? 1 : 0) : 2;

    super.draw(w, h);
  }

  override public function mouseOverHandler(event:MouseEvent):void {
    StatefulBorder(border).stateIndex = myComponent.state == CellState.ON ? 0 : 1;
    super.mouseOverHandler(event);
  }

  override public function mouseOutHandler(event:MouseEvent):void {
    StatefulBorder(border).stateIndex = myComponent.state == CellState.ON ? 1 : 0;
    super.mouseOverHandler(event);
  }

  override protected function mouseUp():void {
    super.mouseUp();

    StatefulBorder(border).stateIndex = 0;
  }
}
}