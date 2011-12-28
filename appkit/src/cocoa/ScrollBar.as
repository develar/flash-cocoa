package cocoa {
[Abstract]
internal class ScrollBar extends Slider {
  public function ScrollBar(vertical:Boolean) {
    super();

    if (vertical) {
      flags |= VERTICAL;
    }
  }
}
}