package cocoa {
import flash.geom.Rectangle;

public class ListView extends SegmentedControl implements ContentView {
  public function ListView() {
    _lafKey = "ListView";
  }

  public function invalidateSubview(invalidateSuperview:Boolean = true):void {
    if (invalidateSuperview) {
      invalidateSize();
    }
  }

  override protected function draw(w:int, h:int):void {
    if (clipAndEnableScrolling) {
      scrollRect = new Rectangle(horizontalScrollPosition, verticalScrollPosition, w, h);
    }

    super.draw(w, h);
  }
}
}