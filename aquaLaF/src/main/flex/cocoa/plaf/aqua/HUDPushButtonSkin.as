package cocoa.plaf.aqua {
import cocoa.CellState;
import cocoa.border.StatefulBorder;
import cocoa.plaf.basic.PushButtonSkin;

public class HUDPushButtonSkin extends cocoa.plaf.basic.PushButtonSkin {
  override protected function draw(w:Number, h:Number):void {
    StatefulBorder(border).stateIndex = myComponent.state == CellState.ON ? 1 : 0;

    super.draw(w, h);
  }
}
}