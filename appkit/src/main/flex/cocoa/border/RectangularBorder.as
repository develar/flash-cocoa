package cocoa.border {
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

public class RectangularBorder extends AbstractBorder {
  private var _layoutHeight:Number;

  private var fillColor:Number;
  private var strokeColor:Number;
  private var cornerRadius:Number;

  public function RectangularBorder(layoutHeight:Number, contentInsets:Insets, fillColor:Number, strokeColor:Number = NaN, cornerRadius:Number = NaN) {
    super();

    _layoutHeight = layoutHeight;
    _contentInsets = contentInsets;

    this.fillColor = fillColor;
    this.strokeColor = strokeColor;
    this.cornerRadius = cornerRadius;
  }

  override public function draw(view:View, g:Graphics, w:Number, h:Number):void {
    const alpha:Number = view == null || view.enabled ? 1 : 0.5;
    if (!isNaN(strokeColor)) {
      g.lineStyle(1, strokeColor, alpha);
    }

    if (!isNaN(fillColor)) {
      g.beginFill(fillColor, alpha);
    }

    if (isNaN(cornerRadius)) {
      g.drawRect(0.5, 0.5, w - 1, h - 1);
    }
    else {
      g.drawRoundRect(0.5, 0.5, w - 1, h - 1, cornerRadius);
    }

    if (!isNaN(fillColor)) {
      g.endFill();
    }
  }

  override public function get layoutHeight():Number {
    return _layoutHeight;
  }
}
}