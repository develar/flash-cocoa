package cocoa.border {
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.GraphicsGradientFill;
import flash.display.IGraphicsData;
import flash.geom.Matrix;

public class LinearGradientBorder extends RectangularBorder {
  private static const sharedMatrix:Matrix = new Matrix();

  private const graphicsData:Vector.<IGraphicsData> = new Vector.<IGraphicsData>(1, true);
  private var vertical:Boolean = true;

  public function LinearGradientBorder(colors:Array, strokeColor:Number, cornerRadius:Number, contentInsets:Insets = null, frameInsets:FrameInsets = null) {
    graphicsData[0] = new GraphicsGradientFill(GradientType.LINEAR, colors, [1, 1], [0, 255], sharedMatrix);

    super(NaN, strokeColor, cornerRadius, contentInsets, frameInsets);
  }

  public static function createV(colors:Array, strokeColor:Number, contentInsets:Insets = null, frameInsets:FrameInsets = null):RectangularBorder {
    return new LinearGradientBorder(colors, strokeColor, NaN, contentInsets, frameInsets);
  }

  public static function createVWithFixedHeight(layoutHeight:Number, colors:Array, strokeColor:Number = NaN):RectangularBorder {
    var border:LinearGradientBorder = new LinearGradientBorder(colors, strokeColor, NaN);
    border._layoutHeight = layoutHeight;
    return border;
  }

  public static function createHRounded(colors:Array, strokeColor:Number, cornerRadius:Number, contentInsets:Insets = null, frameInsets:FrameInsets = null):RectangularBorder {
    var border:LinearGradientBorder = new LinearGradientBorder(colors, strokeColor, cornerRadius, contentInsets, frameInsets);
    border.vertical = false;
    return border;
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

    sharedMatrix.createGradientBox(w, h, vertical ? (Math.PI / 2) : 0, _frameInsets.left, _frameInsets.top);

    g.drawGraphicsData(graphicsData);
    if (cornerRadius != cornerRadius) {
      g.drawRect(_frameInsets.left + offset, _frameInsets.top + offset, w, h);
    }
    else {
      g.drawRoundRect(_frameInsets.left + offset, _frameInsets.top + offset, w , h, cornerRadius);
    }
    g.endFill();
  }
}
}