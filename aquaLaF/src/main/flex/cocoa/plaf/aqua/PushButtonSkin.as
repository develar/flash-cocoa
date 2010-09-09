package cocoa.plaf.aqua {
import cocoa.CellState;
import cocoa.border.MultipleBorder;
import cocoa.plaf.basic.PushButtonSkin;

public class PushButtonSkin extends cocoa.plaf.basic.PushButtonSkin {
  override protected function updateDisplayList(w:Number, h:Number):void {
    MultipleBorder(border).stateIndex = enabled ? (myComponent.state == CellState.ON ? 1 : 0) : 2;

    super.updateDisplayList(w, h);
  }
}
}