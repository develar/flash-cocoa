package cocoa {
[Abstract]
public class Scroller extends Slider {
  public var contentSize:int;
  
  public function Scroller(vertical:Boolean) {
    super(vertical);
    tick = 1;
  }

  override protected function get primaryLaFKey():String {
    return "Scroller";
  }
}
}