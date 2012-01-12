package cocoa.border {
import cocoa.View;

import flash.display.Graphics;

public class Scale3EdgeVBitmapBorder extends Scale3EdgeHBitmapBorder {
  protected var _layoutWidth:Number;

  override public function get layoutWidth():Number {
    return _layoutWidth;
  }

  override public function draw(g:Graphics, w:Number = NaN, h:Number = NaN, x:Number = 0, y:Number = 0, view:View = null):void {
    sharedMatrix.tx = x + _frameInsets.left;
    sharedMatrix.ty = y + _frameInsets.top;

    if (h != h) {
      throw new ArgumentError("h must be determinated for Scale3EdgeVBitmapBorder");
    }

    const actualWidth:Number = w == w ? w - _frameInsets.left - _frameInsets.right : bitmaps[_bitmapIndex].width;
    const rightSliceRelativeY:Number = h - lastSize - _frameInsets.bottom;
    g.beginBitmapFill(bitmaps[_bitmapIndex], sharedMatrix, false);
    g.drawRect(sharedMatrix.tx, sharedMatrix.ty, actualWidth, rightSliceRelativeY - _frameInsets.top);
    g.endFill();

    sharedMatrix.ty = y + rightSliceRelativeY;
    g.beginBitmapFill(bitmaps[_bitmapIndex + 1], sharedMatrix, false);
    g.drawRect(sharedMatrix.tx, sharedMatrix.ty, actualWidth, lastSize);
    g.endFill();
  }

  override protected function initTransient():void {
    size = bitmaps[0].width;
    lastSize = bitmaps[1].height;
    _layoutWidth = size + _frameInsets.top + _frameInsets.bottom;
  }
}
}