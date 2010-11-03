package cocoa.border {
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

public class RectangularBorder extends AbstractBorder {
  private static const DEFAULT_FRAME_INSETS:FrameInsets = new FrameInsets(0.5, 0.5, 0.5, 0.5);

  private var _layoutHeight:Number;

  private var fillColor:Number;
  private var strokeColor:Number;
  private var cornerRadius:Number;

  public function RectangularBorder(layoutHeight:Number, contentInsets:Insets, fillColor:Number, strokeColor:Number = NaN, cornerRadius:Number = NaN, frameInsets:FrameInsets = null) {
    super();

    _layoutHeight = layoutHeight;
    _contentInsets = contentInsets;

    _frameInsets = frameInsets == null ? DEFAULT_FRAME_INSETS : frameInsets;

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
      g.drawRect(_frameInsets.left, _frameInsets.top, w - _frameInsets.left - _frameInsets.right, h - _frameInsets.bottom - _frameInsets.top);
    }
    else {
      g.drawRoundRect(_frameInsets.left, _frameInsets.top, w - _frameInsets.left - _frameInsets.right, h - _frameInsets.bottom - _frameInsets.top, cornerRadius);
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