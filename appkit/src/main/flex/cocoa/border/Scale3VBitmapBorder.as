package cocoa.border {
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

public class Scale3VBitmapBorder extends AbstractScale3BitmapBorder {
  protected var firstSize:Number;

  private var _layoutWidth:Number;
  override public function get layoutWidth():Number {
    return _layoutWidth;
  }

  public static function create(frameInsets:FrameInsets, contentInsets:Insets = null):Scale3VBitmapBorder {
    var border:Scale3VBitmapBorder = new Scale3VBitmapBorder();
    border.init(frameInsets, contentInsets);
    return border;
  }

  override public function draw(g:Graphics, w:Number, h:Number, x:Number = 0, y:Number = 0, view:View = null):void {
    sharedMatrix.tx = _frameInsets.left;
    sharedMatrix.ty = _frameInsets.top;

    g.beginBitmapFill(bitmaps[_bitmapIndex], sharedMatrix, false);
    g.drawRect(_frameInsets.left, _frameInsets.top, size, firstSize);
    g.endFill();

    const centerSliceY:Number = sharedMatrix.ty = _frameInsets.top + firstSize;
    const lastSliceY:Number = h - lastSize - _frameInsets.bottom;
    g.beginBitmapFill(bitmaps[_bitmapIndex + 1], sharedMatrix, true);
    g.drawRect(_frameInsets.left, centerSliceY, size, lastSliceY - centerSliceY);
    g.endFill();

    sharedMatrix.ty = lastSliceY;
    g.beginBitmapFill(bitmaps[_bitmapIndex + 2], sharedMatrix, false);
    g.drawRect(_frameInsets.left, lastSliceY, size, lastSize);
    g.endFill();
  }

  override protected function initTransient():void {
    size = bitmaps[0].width;
    firstSize = bitmaps[0].height;
    lastSize = bitmaps[2].height;

    _layoutWidth = size + _frameInsets.left + _frameInsets.right;
    _layoutHeight = firstSize + lastSize + _frameInsets.top + _frameInsets.bottom;
  }
}
}