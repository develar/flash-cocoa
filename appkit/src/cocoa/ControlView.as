package cocoa {
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;

import mx.core.IMXMLObject;

import org.flyti.plexus.Injectable;
import org.flyti.plexus.events.InjectorEvent;

[Abstract]
public class ControlView extends SpriteBackedView implements IMXMLObject {
  protected var superview:ContentView;

  override public function validate():void {
    if ((flags & LayoutState.DISPLAY_INVALID) == 0) {
      return;
    }

    flags &= ~LayoutState.DISPLAY_INVALID;
    flags &= ~LayoutState.SIZE_INVALID;
    draw(_actualWidth, _actualHeight);
  }

  override public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    super.addToSuperview(displayObjectContainer, laf, superview);
    this.superview = superview;

    if (this is Injectable) {
      dispatchEvent(new InjectorEvent(this, linkId));
    }
  }

  override public function setSize(w:int, h:int):void {
    var resized:Boolean = false;
    if (w != _actualWidth) {
      _actualWidth = w;
      resized = true;
    }
    if (h != _actualHeight) {
      _actualHeight = h;
      resized = true;
    }
    
    super.setSize(w, h);

    if (resized) {
      // after setBounds/setLocation/setSize superview call subview validate in any case — subview doesn't need to invalidate container
      flags |= LayoutState.DISPLAY_INVALID;
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
