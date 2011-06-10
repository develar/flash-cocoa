package cocoa.plaf.aqua {
import cocoa.CellState;
import cocoa.Insets;
import cocoa.TextInsets;
import cocoa.border.MultipleBorder;
import cocoa.plaf.basic.PushButtonSkin;

import flash.display.Graphics;
import flash.events.MouseEvent;

public class CheckBoxSkin extends cocoa.plaf.basic.PushButtonSkin {
  override protected function get toggled():Boolean {
    return true;
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    MultipleBorder(border).stateIndex = myComponent.state == CellState.ON ? 2 : 0;
    alpha = enabled ? 1 : 0.5;

    if (labelHelper != null && labelHelper.hasText) {
      if (border != null && (!isNaN(explicitWidth) || !isNaN(percentWidth))) {
        var titleInsets:Insets = border.contentInsets;
        labelHelper.adjustWidth(w - titleInsets.left - (titleInsets is TextInsets ? TextInsets(titleInsets).truncatedTailMargin : titleInsets.right));
      }

      labelHelper.validate();
      labelHelper.moveByInsets(h, border.contentInsets);
    }

    var g:Graphics = graphics;
    g.clear();
    border.draw(g, border.layoutWidth, h, 0, 0, this);
  }

  override protected function mouseOverHandler(event:MouseEvent):void {
    MultipleBorder(border).stateIndex = myComponent.state == CellState.ON ? 3 : 1;
    super.mouseOverHandler(event);
  }

  override protected function mouseOutHandler(event:MouseEvent):void {
    MultipleBorder(border).stateIndex = myComponent.state == CellState.ON ? 2 : 0;
    super.mouseOverHandler(event);
  }

  override protected function mouseUp():void {
    MultipleBorder(border).stateIndex = myComponent.state == CellState.ON ? 2 : 0;
  }
}
}