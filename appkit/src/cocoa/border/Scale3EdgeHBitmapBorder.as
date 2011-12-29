package cocoa.border {
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

/**
 * Fixed height, arbitrary width — scaled horizontally only.
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

  override public function draw(g:Graphics, w:Number = NaN, h:Number = NaN, x:Number = 0, y:Number = 0, view:View = null):void {
    sharedMatrix.tx = x + _frameInsets.left;
    sharedMatrix.ty = y + _frameInsets.top;

    const actualHeight:Number = h == h ? h - _frameInsets.top - _frameInsets.bottom : bitmaps[_bitmapIndex].height;
    const rightSliceRelativeX:Number = w - lastSize - _frameInsets.right;
    g.beginBitmapFill(bitmaps[_bitmapIndex], sharedMatrix, false);
    g.drawRect(sharedMatrix.tx, sharedMatrix.ty, rightSliceRelativeX - _frameInsets.left, actualHeight);
    g.endFill();

    sharedMatrix.tx = x + rightSliceRelativeX;
    g.beginBitmapFill(bitmaps[_bitmapIndex + 1], sharedMatrix, false);
    g.drawRect(sharedMatrix.tx, sharedMatrix.ty, lastSize, actualHeight);
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