package cocoa {
[Abstract]
public class ScrollBar extends Slider {
  public function ScrollBar(vertical:Boolean) {
    super(vertical);
  }

  override protected function get primaryLaFKey():String {
    return "ScrollBar";
  }
}
}