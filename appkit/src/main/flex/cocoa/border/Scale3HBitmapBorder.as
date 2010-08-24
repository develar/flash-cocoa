package cocoa.border {
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

/**
 * В отличие от Scale3EdgeHBitmapBorder масштабирует честно без уловок тремя кусочками (то есть центральный кусочек может быть более чем 1 px)
 */
public class Scale3HBitmapBorder extends AbstractScale3BitmapBorder {
  protected var firstSize:Number;

  override protected function get serialTypeId():int {
    return 4;
  }

  public static function create(frameInsets:FrameInsets, contentInsets:Insets = null):Scale3HBitmapBorder {
    var border:Scale3HBitmapBorder = new Scale3HBitmapBorder();
    border.init(frameInsets, contentInsets);
    return border;
  }

  override public function draw(view:View, g:Graphics, w:Number, h:Number):void {
    sharedMatrix.tx = _frameInsets.left;
    sharedMatrix.ty = _frameInsets.top;

    g.beginBitmapFill(bitmaps[_bitmapIndex], sharedMatrix, false);
    g.drawRect(_frameInsets.left, _frameInsets.top, firstSize, size);
    g.endFill();

    const centerSliceX:Number = sharedMatrix.tx = _frameInsets.left + firstSize;
    const lastSliceX:Number = w - lastSize - _frameInsets.right;
    g.beginBitmapFill(bitmaps[_bitmapIndex + 1], sharedMatrix, true);
    g.drawRect(centerSliceX, sharedMatrix.ty, lastSliceX - centerSliceX, size);
    g.endFill();

    sharedMatrix.tx = lastSliceX;
    g.beginBitmapFill(bitmaps[_bitmapIndex + 2], sharedMatrix, false);
    g.drawRect(lastSliceX, sharedMatrix.ty, lastSize, size);
    g.endFill();
  }

  override protected function initTransient():void {
    size = bitmaps[0].height;
    firstSize = bitmaps[0].width;
    lastSize = bitmaps[2].width;

    _layoutWidth = size + _frameInsets.left + _frameInsets.right;
    _layoutHeight = size + _frameInsets.top + _frameInsets.bottom;
  }

  private var _layoutWidth:Number;
  override public function get layoutWidth():Number {
    return _layoutWidth;
  }
}
}