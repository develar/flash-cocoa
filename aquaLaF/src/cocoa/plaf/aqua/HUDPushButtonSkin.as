package cocoa.plaf.aqua {
import cocoa.CellState;
import cocoa.border.StatefulBorder;
import cocoa.plaf.basic.PushButtonSkin;

public class HUDPushButtonSkin extends cocoa.plaf.basic.PushButtonSkin {
  override protected function draw(w:int, h:int):void {
    StatefulBorder(border).stateIndex = button.state == CellState.ON ? CellState.ON : CellState.OFF;

    super.draw(w, h);
  }
}
}