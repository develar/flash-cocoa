package cocoa.plaf.aqua {
import cocoa.border.AbstractBorder;
import cocoa.Insets;
import cocoa.View;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;

internal class ListViewBorder extends AbstractBorder {
  private static const CONTENT_INSETS:Insets = new Insets(1, 1, 1, 1);

  private static const HALF_LINE_THICKNESS:Number = 0.5;

  public function ListViewBorder() {
    super();

    _contentInsets = CONTENT_INSETS;
  }

  override public function draw(view:View, g:Graphics, w:Number, h:Number):void {
    const right:Number = w - HALF_LINE_THICKNESS;
    const bottom:Number = h - HALF_LINE_THICKNESS;

    g.beginFill(0xffffff);
    g.lineStyle(1, 0xbebebe, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
    g.moveTo(HALF_LINE_THICKNESS, HALF_LINE_THICKNESS);
    g.lineTo(HALF_LINE_THICKNESS, bottom);
    g.lineTo(right, bottom);
    g.lineTo(right, HALF_LINE_THICKNESS);

    g.lineStyle(1, 0x8e8e8e, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
    g.lineTo(HALF_LINE_THICKNESS, HALF_LINE_THICKNESS);

    g.endFill();
  }
}
}