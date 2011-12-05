package cocoa.border {
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

public class EmptyBorder extends AbstractBorder {
  private var _layoutHeight:Number;

  public function EmptyBorder(layoutHeight:Number, contentInsets:Insets) {
    super();

    _layoutHeight = layoutHeight;
    _contentInsets = contentInsets;
  }

  override public function draw(g:Graphics, w:Number, h:Number, x:Number = 0, y:Number = 0, view:View = null):void {

  }

  override public function get layoutHeight():Number {
    return _layoutHeight;
  }
}
}