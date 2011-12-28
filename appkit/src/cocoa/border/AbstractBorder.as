package cocoa.border {
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

[Abstract]
public class AbstractBorder implements Border {
  public static const EMPTY_FRAME_INSETS:FrameInsets = new FrameInsets();

  public function get layoutHeight():Number {
    return NaN;
  }

  public function get layoutWidth():Number {
    return NaN;
  }

  protected var _frameInsets:FrameInsets = EMPTY_FRAME_INSETS;
  public function get frameInsets():FrameInsets {
    return _frameInsets;
  }

  protected var _contentInsets:Insets = Insets.EMPTY;
  public function get contentInsets():Insets {
    return _contentInsets;
  }

  public function draw(g:Graphics, w:Number = NaN, h:Number = NaN, x:Number = 0, y:Number = 0, view:View = null):void {
    throw new Error("abstract");
  }
}
}