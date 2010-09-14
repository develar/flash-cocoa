package cocoa.border {
import cocoa.View;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;

/**
 * Посмотрите на thumb полосы прокрутки в виджете RSS в iWeb. border для вертикальной полосы прокрутки состоит из fill и top/bottom cap. При этом cap одинаков — просто перевернут. А fill это 1px
 * 0 - top cap, 1 - fill. при отрисовке bottom cap мы просто переворачиваем top cap.
 *
 * layoutWidth/layoutHeight отдается равный ширине cap — полоса прокрутки учитывает только одно из измерений
 */
public class CappedSmartBorder extends AbstractMultipleBitmapBorder {
  private static var bottomSharedMatrix:Matrix;

  override public function get layoutWidth():Number {
    return bitmaps[0].width;
  }

  override public function get layoutHeight():Number {
    return bitmaps[0].width;
  }

  override public function draw(view:View, g:Graphics, w:Number, h:Number):void {
    var cap:BitmapData = bitmaps[0];
    const capHeight:Number = cap.height;

    sharedMatrix.tx = 0;
    sharedMatrix.ty = 0;

    g.beginBitmapFill(cap, sharedMatrix, false);
    g.drawRect(0, 0, w, capHeight);
    g.endFill();
    sharedMatrix.ty = capHeight;

    g.beginBitmapFill(bitmaps[1], sharedMatrix, true);
    g.drawRect(0, capHeight, w, h - (capHeight * 2));
    g.endFill();

    if (bottomSharedMatrix == null) {
      bottomSharedMatrix = new Matrix();
      bottomSharedMatrix.rotate(Math.PI);
      bottomSharedMatrix.tx = cap.width;
    }

    bottomSharedMatrix.ty = h;

    g.beginBitmapFill(cap, bottomSharedMatrix, false);
    g.drawRect(0, h - capHeight, w, capHeight);
    g.endFill();
  }
}
}