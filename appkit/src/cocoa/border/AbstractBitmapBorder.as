package cocoa.border {
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.TextInsets;

import flash.geom.Matrix;
import flash.utils.ByteArray;

public class AbstractBitmapBorder extends AbstractBorder {
  protected static const sharedMatrix:Matrix = new Matrix();

  public function readExternal(input:ByteArray):void {
    if (input.readByte() == 1) {
      var first:int = input.readByte();
      _contentInsets = first == -1 ? new Insets(input.readByte(), input.readByte(), input.readByte(), input.readByte()) : new TextInsets(first, input.readByte(), input.readByte(), input.readByte(), input.readByte());
    }
    if (input.readByte() == 1) {
      _frameInsets = new FrameInsets(input.readByte(), input.readByte(), input.readByte(), input.readByte());
    }
  }
}
}