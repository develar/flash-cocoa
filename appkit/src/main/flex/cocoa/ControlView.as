package cocoa {
[Abstract]
public class ControlView extends AbstractView {
  private static const INVALID:uint = 1 << 1;

  protected var container:Container;

  override public function validate():void {
    if ((flags & INVALID) == 0) {
      return;
    }

    flags &= ~INVALID;
    draw(_actualWidth, _actualHeight);
  }

  override public function init(container:Container):void {
    this.container = container;
  }

  protected function draw(w:int, h:int):void {

  }

  protected final function invalidate(invalidateContainer:Boolean = true):void {
    if (container == null) {
      return;
    }

    if (invalidateContainer) {
      container.invalidateSubview(invalidateContainer);
    }

    flags |= INVALID;
  }
}
}
