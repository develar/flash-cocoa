package cocoa.border {
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

/**
 * Фиксированная высота, произвольная ширина — масштабируется только по горизонтали.
 * Состоит из left, center и right кусочков bitmap — left и right как есть, а повторяется только center.
 * Реализовано как две bitmap, где 1 это склееный left и center — ширина center равна 1px — мы используем "the bitmap image does not repeat, and the edges of the bitmap are used for any fill area that extends beyond the bitmap"
 * (это позволяет нам сократить количество bitmapData, количество вызовов на отрисовку и в целом немного упростить код (в частности, для тех случаев, когда left width == 0)).
 */
public class Scale3EdgeHBitmapBorder extends AbstractScale3BitmapBorder {
  public static function create(frameInsets:FrameInsets = null, contentInsets:Insets = null):Scale3EdgeHBitmapBorder {
    var border:Scale3EdgeHBitmapBorder = new Scale3EdgeHBitmapBorder();
    border.init(frameInsets, contentInsets);
    return border;
  }

  override public function draw(view:View, g:Graphics, w:Number, h:Number):void {
    sharedMatrix.tx = _frameInsets.left;
    sharedMatrix.ty = _frameInsets.top;

    const actualHeight:Number = h - _frameInsets.top - _frameInsets.bottom;
    const rightSliceX:Number = w - lastSize - _frameInsets.right;
    g.beginBitmapFill(bitmaps[_bitmapIndex], sharedMatrix, false);
    g.drawRect(sharedMatrix.tx, sharedMatrix.ty, rightSliceX - _frameInsets.left, actualHeight);
    g.endFill();

    sharedMatrix.tx = rightSliceX;
    g.beginBitmapFill(bitmaps[_bitmapIndex + 1], sharedMatrix, false);
    g.drawRect(rightSliceX, sharedMatrix.ty, lastSize, actualHeight);
    g.endFill();
  }
  
  override protected function initTransient():void {
    size = bitmaps[0].height;
    lastSize = bitmaps[1].width;
    _layoutHeight = size + _frameInsets.top + _frameInsets.bottom;
  }

  override public function set stateIndex(value:int):void {
    _bitmapIndex = value << 1;
  }
}
}