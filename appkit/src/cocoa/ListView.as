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
      drawMouseCatcher(w, h);
    }

    super.draw(w, h);
  }

  private function drawMouseCatcher(w:int, h:int):void {
    if (border == null) {
      graphics.clear();
      graphics.beginFill(0, 0);
      graphics.drawRect(horizontalScrollPosition, verticalScrollPosition, w, h);
      graphics.endFill();
    }
  }

  override protected function verticalScrollPositionChanged(delta:Number, oldVerticalScrollPosition:Number):void {
    if ((flags & LayoutState.DISPLAY_INVALID) == 0) {
      drawMouseCatcher(_actualWidth, _actualHeight);
    }
  }
}
}