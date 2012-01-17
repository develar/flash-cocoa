package cocoa.plaf.basic {
import cocoa.ContentView;
import cocoa.LayoutState;
import cocoa.ObjectBackedView;
import cocoa.SkinnableView;
import cocoa.plaf.Skin;

import flash.errors.IllegalOperationError;

public class ObjectBackedSkin extends ObjectBackedView implements Skin {
  protected var superview:ContentView;

  protected var _x:int;
  protected var _y:int;

  override public function get layoutHashCode():int {
    return flags;
  }

  protected var _actualWidth:int = -1;
  override public function get actualWidth():int {
    return _actualWidth;
  }

  protected var _actualHeight:int = -1;
  override public function get actualHeight():int {
    return _actualHeight;
  }

  override public function setBounds(x:Number, y:Number, w:int, h:int):void {
    _x = x;
    _y = y;

    setSize(w, h);
  }

  public function get component():SkinnableView {
    throw new IllegalOperationError("abstract");
  }

  public function attach(component:SkinnableView):void {
    throw new IllegalOperationError("abstract");
  }

  public function hostComponentPropertyChanged():void {
    invalidate(true);
  }

  protected final function invalidate(sizeInvalid:Boolean = true):void {
    flags |= LayoutState.DISPLAY_INVALID;

    if (sizeInvalid && ((flags & LayoutState.SIZE_INVALID) == 0)) {
      flags |= LayoutState.SIZE_INVALID;
      if (superview != null) {
        superview.invalidateSubview(sizeInvalid);
      }
    }
  }
}
}