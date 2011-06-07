package cocoa.border {
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

import spark.core.IViewport;

public class RectangularBorder extends AbstractBorder {
  private var fillColor:Number;
  protected var strokeColor:Number;
  protected var cornerRadius:Number;

  public function RectangularBorder(fillColor:Number, strokeColor:Number, cornerRadius:Number, contentInsets:Insets, frameInsets:FrameInsets = null) {
    super();

    this.fillColor = fillColor;
    this.strokeColor = strokeColor;

    if (contentInsets != null) {
      _contentInsets = contentInsets;
    }
    if (frameInsets != null) {
      _frameInsets = frameInsets;
    }

    this.cornerRadius = cornerRadius;
  }

  public static function create(fillColor:Number, strokeColor:Number = NaN, contentInsets:Insets = null, frameInsets:FrameInsets = null):RectangularBorder {
    return new RectangularBorder(fillColor, strokeColor, NaN, contentInsets, frameInsets);
  }

  public static function createRounded(fillColor:Number, strokeColor:Number, cornerRadius:Number, contentInsets:Insets = null, frameInsets:FrameInsets = null):RectangularBorder {
    return new RectangularBorder(fillColor, strokeColor, cornerRadius, contentInsets, frameInsets);
  }

  protected var _layoutHeight:Number;
  override public function get layoutHeight():Number {
    return _layoutHeight;
  }

  override public function draw(view:View, g:Graphics, w:Number, h:Number):void {
    const alpha:Number = view == null || view.enabled ? 1 : 0.5;

    if (_frameInsets != EMPTY_FRAME_INSETS) {
      w -= _frameInsets.left + _frameInsets.right;
      h -= _frameInsets.bottom + _frameInsets.top;
    }

    var offset:Number = 0;
    if (strokeColor == strokeColor) {
      g.lineStyle(1, strokeColor, alpha);
      w -= 1;
      h -= 1;
      offset = 0.5;
    }

    if (fillColor == fillColor) {
      g.beginFill(fillColor, alpha);
    }

    var x:Number = _frameInsets.left + offset;
    var y:Number = _frameInsets.top + offset;
    if (view is IViewport) {
      var viewPort:IViewport = IViewport(view);
      x += viewPort.horizontalScrollPosition;
      y += viewPort.verticalScrollPosition;
    }

    if (cornerRadius != cornerRadius) {
      g.drawRect(x, y, w, h);
    }
    else {
      g.drawRoundRect(x, y, w, h, cornerRadius);
    }

    if (fillColor == fillColor) {
      g.endFill();
    }
  }
}
}