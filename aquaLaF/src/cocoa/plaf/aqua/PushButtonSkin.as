package cocoa.plaf.aqua {
import cocoa.CellState;
import cocoa.border.StatefulBorder;
import cocoa.plaf.basic.PushButtonSkin;

import flash.events.MouseEvent;

public class PushButtonSkin extends cocoa.plaf.basic.PushButtonSkin {
  override protected function draw(w:int, h:int):void {
    StatefulBorder(border).stateIndex = enabled ? button.state : 2;

    super.draw(w, h);
  }

  override public function mouseOverHandler(event:MouseEvent):void {
    StatefulBorder(border).stateIndex = button.state == CellState.ON ? CellState.OFF : CellState.ON;
    super.mouseOverHandler(event);
  }

  override public function mouseOutHandler(event:MouseEvent):void {
    StatefulBorder(border).stateIndex = button.state;
    super.mouseOverHandler(event);
  }

  override protected function mouseUp():void {
    super.mouseUp();

    StatefulBorder(border).stateIndex = CellState.OFF;
  }
}
}