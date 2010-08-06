package cocoa.border {
import cocoa.View;

import flash.display.Graphics;

/**
 * Иногда возникает ситуация, что изображение для некого состояния отличается по размеру от других (в нормальном Aqua такого нет, а во Fluent...). А frameInsets мы можем указать только один раз.
 * Данный border берет первое изображение за эталон, а для других рассчитывает поправки к frameInsets. Пока что обработка касается только left и right.
 * В дескрипторе ничего писать особо не нужно — вы указываете Scale3EdgeHBitmap, а система сама поймет что нужно использовать именно этот класс.
 *
 * В отличии от Scale3EdgeHBitmapBorder использует не высоту рассчитанную по h - _frameInsets.top - _frameInsets.bottom, а высоту изображения.
 * Зачем было нужно actualHeight в Scale3EdgeHBitmapBorder я не помню, но вроде как нужно frameInsets указывать и с bottom — border этот нужен только для fluent, как возникнет какая-то проблема с этим — будем думать.
 */
public class Scale3EdgeHBitmapBorderWithSmartFrameInsets extends Scale3EdgeHBitmapBorder {
  override public function draw(view:View, g:Graphics, w:Number, h:Number):void {
    const frameLeft:Number = _frameInsets.left + (bitmaps[0].width - bitmaps[_bitmapIndex].width);

    sharedMatrix.tx = frameLeft;
    sharedMatrix.ty = _frameInsets.top;

    const bitmapHeight:Number = bitmaps[_bitmapIndex].height;
    const rightSliceX:Number = w - lastSize - _frameInsets.right - (bitmaps[1].width - bitmaps[_bitmapIndex + 1].width);
    g.beginBitmapFill(bitmaps[_bitmapIndex], sharedMatrix, false);
    g.drawRect(sharedMatrix.tx, sharedMatrix.ty, rightSliceX - frameLeft, bitmapHeight);
    g.endFill();

    sharedMatrix.tx = rightSliceX;
    g.beginBitmapFill(bitmaps[_bitmapIndex + 1], sharedMatrix, false);
    g.drawRect(rightSliceX, sharedMatrix.ty, lastSize, bitmapHeight);
    g.endFill();
  }
}
}