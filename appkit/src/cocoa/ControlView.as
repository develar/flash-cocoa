package cocoa {
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;

import mx.core.IMXMLObject;

import org.flyti.plexus.Injectable;
import org.flyti.plexus.events.InjectorEvent;

[Abstract]
public class ControlView extends SpriteBackedView implements IMXMLObject {
  protected var superview:ContentView;

  public function ControlView() {
    super();
    flags |= LayoutState.SIZE_INVALID;
  }

  override public function validate():Boolean {
    if ((flags & LayoutState.DISPLAY_INVALID) == 0) {
      return false;
    }

    flags &= ~LayoutState.DISPLAY_INVALID;
    flags &= ~LayoutState.SIZE_INVALID;
    draw(_actualWidth, _actualHeight);
    return true;
  }

  override public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    super.addToSuperview(displayObjectContainer, laf, superview);
    this.superview = superview;

    if (this is Injectable) {
      dispatchEvent(new InjectorEvent(this, linkId));
    }
  }

  protected function draw(w:int, h:int):void {
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

  private var _linkId:String;
  override public function get linkId():String {
    return _linkId;
  }

  public function initialized(document:Object, id:String):void {
    _linkId = id;
  }

  override public function get layoutHashCode():int {
    return flags;
  }
}
}
