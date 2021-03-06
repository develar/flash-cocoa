package cocoa.plaf.basic {
import cocoa.Icon;
import cocoa.View;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;
import flash.utils.ByteArray;

public class BitmapIcon implements Icon {
  private static const sharedMatrix:Matrix = new Matrix();

  private var bitmapData:BitmapData;

  public function BitmapIcon(input:ByteArray = null) {
    this.bitmapData = bitmapData;
  }

  public final function getBitmap():BitmapData {
    return bitmapData;
  }

  public static function create(bitmapData:BitmapData):BitmapIcon {
    var bitmapIcon:BitmapIcon = new BitmapIcon();
    bitmapIcon.bitmapData = bitmapData;
    return bitmapIcon;
  }

  public static function createByBitmapClass(bitmapClass:Class):BitmapIcon {
    return create(Bitmap(new bitmapClass()).bitmapData);
  }

  public function get iconWidth():Number {
    return bitmapData.width;
  }

  public function get iconHeight():Number {
    return bitmapData.height;
  }

  public function draw(view:View, g:Graphics, x:Number, y:Number):void {
    sharedMatrix.tx = x;
    sharedMatrix.ty = y;
    g.beginBitmapFill(bitmapData, sharedMatrix, false);
    g.drawRect(x, y, iconWidth, iconHeight);
    g.endFill();
  }

  public function readExternal(input:ByteArray):void {
    bitmapData = new BitmapData(input.readUnsignedByte(), input.readUnsignedByte(), true, 0);
    bitmapData.setPixels(bitmapData.rect, input);
  }
}
}