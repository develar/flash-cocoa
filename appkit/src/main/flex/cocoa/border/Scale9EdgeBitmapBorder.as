package cocoa.border {
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.utils.ByteArray;

/**
 * Тот же трюк, что и в Scale3EdgeHBitmapBorder — отрисовка scale9Grid требует всего 4, а не 9 кусочков
 */
public final class Scale9EdgeBitmapBorder extends AbstractMultipleBitmapBorder {
  private var rightSliceInnerWidth:int;
  private var bottomSliceInnerHeight:int;

  public static function create(frameInsets:FrameInsets = null, contentInsets:Insets = null):Scale9EdgeBitmapBorder {
    var border:Scale9EdgeBitmapBorder = new Scale9EdgeBitmapBorder();
    if (frameInsets != null) {
      border._frameInsets = frameInsets;
    }
    if (contentInsets != null) {
      border._contentInsets = contentInsets;
    }
    return border;
  }

  public function configure(bitmaps:Vector.<BitmapData>):Scale9EdgeBitmapBorder {
    this.bitmaps = bitmaps;

    rightSliceInnerWidth = bitmaps[1].width + _frameInsets.right;
    bottomSliceInnerHeight = bitmaps[2].height + _frameInsets.bottom;

    return this;
  }

  override public function draw(view:View, g:Graphics, w:Number, h:Number):void {
    sharedMatrix.tx = _frameInsets.left;
    sharedMatrix.ty = _frameInsets.top;

    const rightSliceX:Number = w - rightSliceInnerWidth;
    const bottomSliceY:Number = h - bottomSliceInnerHeight;

    const topAreaHeight:Number = bottomSliceY - _frameInsets.top;
    const bottomAreaHeight:Number = bitmaps[_bitmapIndex + 2].height;
    const leftAreaWidth:Number = rightSliceX - _frameInsets.left;
    const rightAreaWidth:Number = bitmaps[_bitmapIndex + 1].width;

    g.beginBitmapFill(bitmaps[_bitmapIndex], sharedMatrix, false);
    g.drawRect(_frameInsets.left, sharedMatrix.ty, leftAreaWidth, topAreaHeight);
    g.endFill();

    sharedMatrix.tx = rightSliceX;
    g.beginBitmapFill(bitmaps[_bitmapIndex + 1], sharedMatrix, false);
    g.drawRect(rightSliceX, sharedMatrix.ty, rightAreaWidth, topAreaHeight);
    g.endFill();

    sharedMatrix.ty = bottomSliceY;

    sharedMatrix.tx = _frameInsets.left;
    g.beginBitmapFill(bitmaps[_bitmapIndex + 2], sharedMatrix, false);
    g.drawRect(_frameInsets.left, bottomSliceY, leftAreaWidth, bottomAreaHeight);
    g.endFill();

    sharedMatrix.tx = rightSliceX;
    g.beginBitmapFill(bitmaps[_bitmapIndex + 3], sharedMatrix, false);
    g.drawRect(rightSliceX, bottomSliceY, rightAreaWidth, bottomAreaHeight);
    g.endFill();
  }

  override public function readExternal(input:ByteArray):void {
    super.readExternal(input);

    _frameInsets = readFrameInsets(input);

    rightSliceInnerWidth = bitmaps[1].width + _frameInsets.right;
    bottomSliceInnerHeight = bitmaps[2].height + _frameInsets.bottom;
  }

  override public function writeExternal(output:ByteArray):void {
    output.writeByte(2);

    super.writeExternal(output);

    writeFrameInsets(output);
  }

  override public function set stateIndex(value:int):void {
    _bitmapIndex = value << 2;
  }
}
}