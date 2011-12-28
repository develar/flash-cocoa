package cocoa.plaf.aqua {
import cocoa.View;
import cocoa.border.AbstractBorder;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;

public class SeparatorBorder extends AbstractBorder {
  override public function draw(g:Graphics, w:Number = NaN, h:Number = NaN, x:Number = 0, y:Number = 0, view:View = null):void {
    g.lineStyle(1, 0xffffff, 0.3, false, LineScaleMode.NORMAL, CapsStyle.NONE);
    g.moveTo(0, h);
    g.lineTo(w, h);
  }

  override public function get layoutWidth():Number {
    return -100;
  }

  override public function get layoutHeight():Number {
    return 1;
  }
}
}