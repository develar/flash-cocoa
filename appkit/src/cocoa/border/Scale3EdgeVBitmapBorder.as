package cocoa.border {
import cocoa.View;

import flash.display.Graphics;

public class Scale3EdgeVBitmapBorder extends Scale3EdgeHBitmapBorder {
  override public function draw(g:Graphics, w:Number = NaN, h:Number = NaN, x:Number = 0, y:Number = 0, view:View = null):void {
    sharedMatrix.tx = x + _frameInsets.left;
    sharedMatrix.ty = y + _frameInsets.top;

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
}
}