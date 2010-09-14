package cocoa.plaf.basic.scrollbar {
public class VScrollBarSkin extends AbstractScrollBarSkin {
  override protected function get orientation():String {
    return "v";
  }

  override protected function measure():void {
    measuredMinWidth = measuredWidth = track.getExplicitOrMeasuredWidth();
    measuredMinHeight = measuredHeight = thumb.getExplicitOrMeasuredHeight() + decrementButton.getExplicitOrMeasuredHeight() + incrementButton.getExplicitOrMeasuredHeight();
  }

  override protected function layoutTrackAndButtons(w:Number, h:Number):void {
    const incrementButtonHeight:Number = incrementButton.getPreferredBoundsHeight();
    const decrementButtonY:Number = h - decrementButton.getPreferredBoundsHeight() - incrementButtonHeight;

    track.setLayoutBoundsSize(NaN, decrementButtonY);

    decrementButton.setLayoutBoundsPosition(0, decrementButtonY);
    incrementButton.setLayoutBoundsPosition(0, h - incrementButtonHeight);
  }
}
}