package cocoa.border {
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

public class EmptyBorder extends AbstractBorder {
  private var _layoutHeight:Number;

  public function EmptyBorder(layoutHeight:Number = NaN, contentInsets:Insets = null) {
    super();

    _layoutHeight = layoutHeight;
    if (contentInsets != null) {
      _contentInsets = contentInsets;
    }
  }

  override public function draw(g:Graphics, w:Number = NaN, h:Number = NaN, x:Number = 0, y:Number = 0, view:View = null):void {

  }

  override public function get layoutHeight():Number {
    return _layoutHeight;
  }
}
}