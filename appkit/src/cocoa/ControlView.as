package cocoa {
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;

import mx.core.IMXMLObject;

import org.flyti.plexus.Injectable;
import org.flyti.plexus.events.InjectorEvent;

[Abstract]
public class ControlView extends SpriteBackedView implements IMXMLObject {
  protected static const INVALID:uint = 1 << 2;

  protected var superview:ContentView;

  override public function validate():void {
    if ((flags & INVALID) == 0) {
      return;
    }

    flags &= ~INVALID;
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
    if (width != _actualWidth) {
      _actualWidth = width;
      resized = true;
    }
    if (height != _actualHeight) {
      _actualHeight = height;
      resized = true;
    }
    
    super.setSize(w, h);

    if (resized) {
      // after setBounds/setLocation superview call subview validdate in any case — subview doesn't need to invalidate container
      invalidate(false);
    }
  }

  protected function draw(w:int, h:int):void {

  }

  protected final function invalidate(invalidateSuperview:Boolean = true):void {
    flags |= INVALID;

    if (invalidateSuperview && superview != null) {
      superview.invalidateSubview(invalidateSuperview);
    }
  }

  private var _linkId:String;

  override public function get linkId():String {
    return _linkId;
  }

  public function initialized(document:Object, id:String):void {
    _linkId = id;
  }
}
}
