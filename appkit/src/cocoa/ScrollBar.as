package cocoa {
[Abstract]
internal class ScrollBar extends ControlView {
  protected static const VERTICAL:uint = 1 << 4;

  public function ScrollBar(vertical:Boolean) {
    super();

    if (vertical) {
      flags |= VERTICAL;
    }
  }
}
}
