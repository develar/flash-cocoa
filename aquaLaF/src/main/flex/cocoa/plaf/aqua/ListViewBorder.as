package cocoa.plaf.aqua {
import cocoa.border.AbstractBorder;
import cocoa.Insets;
import cocoa.View;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;

internal class ListViewBorder extends AbstractBorder {
  private static const CONTENT_INSETS:Insets = new Insets(1, 1, 1, 1);

  private var backgroundColor:uint;

  public function ListViewBorder(backgroundColor:uint = 0xffffff, margin:Number = NaN) {
    super();

    _contentInsets = isNaN(margin) ? CONTENT_INSETS : new Insets(margin, margin, margin, margin);
    this.backgroundColor = backgroundColor;
  }

  override public function draw(view:View, g:Graphics, w:Number, h:Number):void {
    const left:Number = 0.5;
    const top:Number = 0.5;
    const right:Number = w - 0.5;
    const bottom:Number = h - 0.5;

    g.beginFill(backgroundColor);
    g.lineStyle(1, 0xbebebe, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
    g.moveTo(left, top);
    g.lineTo(left, bottom);
    g.lineTo(right, bottom);
    g.lineTo(right, top);

    g.lineStyle(1, 0x8e8e8e, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
    g.lineTo(left, top);

    g.endFill();
  }
}
}