package cocoa.plaf.aqua {
import cocoa.CellState;
import cocoa.Insets;
import cocoa.TextInsets;
import cocoa.border.StatefulBorder;
import cocoa.plaf.basic.PushButtonSkin;

import flash.display.Graphics;
import flash.events.MouseEvent;

public class CheckBoxSkin extends cocoa.plaf.basic.PushButtonSkin {
  override protected function get toggled():Boolean {
    return true;
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    StatefulBorder(border).stateIndex = (myComponent.state * 3) + (enabled ? 0 : 2);

    if (labelHelper != null && labelHelper.hasText) {
      if (border != null && (!isNaN(explicitWidth) || !isNaN(percentWidth))) {
        var titleInsets:Insets = border.contentInsets;
        labelHelper.adjustWidth(w - titleInsets.left - (titleInsets is TextInsets ? TextInsets(titleInsets).truncatedTailMargin : titleInsets.right));
      }

      labelHelper.validate();
      labelHelper.moveByInsets(h, border.contentInsets);

      labelHelper.textLine.alpha = enabled ? 1 : 0.5;
    }

    drawBorder2(w, h);
  }

  override public function mouseOverHandler(event:MouseEvent):void {
    StatefulBorder(border).stateIndex = myComponent.state == CellState.ON ? 4 : 1;
    super.mouseOverHandler(event);
  }

  override public function mouseOutHandler(event:MouseEvent):void {
    StatefulBorder(border).stateIndex = myComponent.state == CellState.ON ? 3 : 0;
    super.mouseOverHandler(event);
  }

  override protected function mouseUp():void {
    super.mouseUp();

    StatefulBorder(border).stateIndex = myComponent.state == CellState.ON ? 3 : 0;
  }

  override protected function drawBorder2(w:Number, h:Number):void {
    var g:Graphics = graphics;
    g.clear();
    // checkmark вылезает за пределы обычной картинки, а на border у нас только один frameInsers, — дорабатывать концепцию дорого
    border.draw(g, NaN, NaN, 0, myComponent.state == CellState.ON ? -2 : 0, this);
  }
}
}