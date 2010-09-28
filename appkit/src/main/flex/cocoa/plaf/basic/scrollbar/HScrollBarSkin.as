package cocoa.plaf.basic.scrollbar {
public class HScrollBarSkin extends AbstractScrollBarSkin {
  override protected function get isVertical():Boolean {
    return false;
  }

  override protected function layoutTrackAndButtons(w:Number, h:Number):void {
    const incrementButtonWidth:Number = incrementButton.getPreferredBoundsWidth();
    const decrementButtonX:Number = w - decrementButton.getPreferredBoundsWidth() - incrementButtonWidth;

    track.setLayoutBoundsSize(decrementButtonX, NaN);

    decrementButton.setLayoutBoundsPosition(decrementButtonX, 0);
    incrementButton.setLayoutBoundsPosition(w - incrementButtonWidth, 0);
  }
}
}