package cocoa.border {
import cocoa.Border;
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

// для тех же целей, что и http://java.sun.com/javase/6/docs/api/javax/swing/border/CompoundBorder.html
public class CompoundBorder extends AbstractBorder {
  public function CompoundBorder(contentInsets:Insets, insideBorder:Border, layoutHeight:Number = NaN) {
    super();

    _contentInsets = contentInsets;
    _insideBorder = insideBorder;

    _layoutHeight = isNaN(layoutHeight) ? insideBorder.layoutHeight : layoutHeight;
  }

  private var _insideBorder:Border;
  public function get insideBorder():Border {
    return _insideBorder;
  }

  private var _layoutHeight:Number;
  override public function get layoutHeight():Number {
    return _layoutHeight;
  }

  override public function draw(g:Graphics, w:Number, h:Number, x:Number = 0, y:Number = 0, view:View = null):void {
    insideBorder.draw(g, w, h, 0, 0, view);
  }
}
}