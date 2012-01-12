package cocoa {
[Abstract]
public class Scroller extends Slider {
  public function Scroller(vertical:Boolean) {
    super(vertical);
  }

  override protected function get primaryLaFKey():String {
    return "Scroller";
  }
}
}