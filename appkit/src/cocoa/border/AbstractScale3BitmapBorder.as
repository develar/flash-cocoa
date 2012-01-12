package cocoa.border {
import cocoa.FrameInsets;
import cocoa.Insets;

import flash.display.BitmapData;
import flash.utils.ByteArray;

internal class AbstractScale3BitmapBorder extends AbstractControlBitmapBorder {
  // Fixed dimension of each slice (depends from orientation, height if horizontal, width if vertical)
  protected var size:Number;
  protected var lastSize:Number;

  protected function init(frameInsets:FrameInsets = null, contentInsets:Insets = null):void {
    if (frameInsets != null) {
      _frameInsets = frameInsets;
    }
    if (contentInsets != null) {
      _contentInsets = contentInsets;
    }
  }

  public function configure(bitmaps:Vector.<BitmapData>):AbstractScale3BitmapBorder {
    this.bitmaps = bitmaps;
    initTransient();
    return this;
  }

  protected function initTransient():void {
    throw new Error("abstract");
  }

  override public function readExternal(input:ByteArray):void {
    super.readExternal(input);

    initTransient();
  }
}
}