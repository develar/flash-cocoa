package cocoa.plaf.aqua {
import cocoa.Border;
import cocoa.View;
import cocoa.border.AbstractBorder;

import flash.display.Graphics;

public final class MenuItemBorder extends AbstractBorder {
  private var _layoutHeight:Number;

  public function MenuItemBorder(higlightedBorder:Border) {
    _contentInsets = higlightedBorder.contentInsets;
    _layoutHeight = higlightedBorder.layoutHeight;
  }

  override public function get layoutHeight():Number {
    return _layoutHeight;
  }

  override public function draw(g:Graphics, w:Number, h:Number, x:Number = 0, y:Number = 0, view:View = null):void {
    g.beginFill(0xffffff, 242 / 255);
    g.drawRect(0, 0, w, h);
    g.endFill();
  }
}
}