package cocoa.plaf.basic.scrollbar {
public class VScrollBarSkin extends AbstractScrollBarSkin {
  override protected function get isVertical():Boolean {
    return true;
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