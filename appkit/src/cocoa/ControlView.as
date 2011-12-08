package cocoa {
[Abstract]
public class ControlView extends SpriteBackedView {
  protected static const INVALID:uint = 1 << 2;

  protected var superview:ContentView;

  override public function validate():void {
    if ((flags & INVALID) == 0) {
      return;
    }

    flags &= ~INVALID;
    draw(_actualWidth, _actualHeight);
  }

  override public function addToSuperview(superview:ContentView):void {
    super.addToSuperview(superview);
    this.superview = superview;
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
}
}
