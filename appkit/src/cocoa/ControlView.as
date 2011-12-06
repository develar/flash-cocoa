package cocoa {
[Abstract]
public class ControlView extends SpriteBackedView {
  protected static const INVALID:uint = 1 << 1;

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

  protected function draw(w:int, h:int):void {

  }

  protected final function invalidate(invalidateSuperview:Boolean = true):void {
    if (superview == null) {
      return;
    }

    if (invalidateSuperview) {
      superview.invalidateSubview(invalidateSuperview);
    }

    flags |= INVALID;
  }
}
}
