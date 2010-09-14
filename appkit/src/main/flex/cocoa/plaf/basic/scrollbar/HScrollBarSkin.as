package cocoa.plaf.basic.scrollbar {
public class HScrollBarSkin extends AbstractScrollBarSkin {
  override protected function get orientation():String {
    return "h";
  }

  override protected function measure():void {
    measuredMinWidth = measuredWidth = thumb.getExplicitOrMeasuredWidth() + decrementButton.getExplicitOrMeasuredWidth() + incrementButton.getExplicitOrMeasuredWidth();
    measuredMinHeight = measuredHeight = track.getExplicitOrMeasuredHeight();
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