package cocoa.border {
import cocoa.FrameInsets;
import cocoa.View;

import flash.display.GradientType;
import flash.display.Graphics;
import flash.display.GraphicsGradientFill;
import flash.display.IGraphicsData;
import flash.geom.Matrix;

public class LinearGradientBorder extends AbstractBorder {
  private static const sharedMatrix:Matrix = new Matrix();

  private const graphicsData:Vector.<IGraphicsData> = new Vector.<IGraphicsData>(1, true);

  public function LinearGradientBorder(colors:Array, frameInsets:FrameInsets = null) {
    graphicsData[0] = new GraphicsGradientFill(GradientType.LINEAR, colors, [1, 1], [0, 255], sharedMatrix);

    if (frameInsets != null) {
      _frameInsets = frameInsets;
    }
  }

  override public function draw(view:View, g:Graphics, w:Number, h:Number):void {
    h -= _frameInsets.top + _frameInsets.bottom;
    sharedMatrix.createGradientBox(w, h, Math.PI / 2, 0, _frameInsets.top);

    g.drawGraphicsData(graphicsData);
    g.drawRect(0, _frameInsets.top, w, h);
    g.endFill();
  }
}
}