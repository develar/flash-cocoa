package cocoa.plaf.aqua {
public class TextAreaSkin extends TextInputSkin {
  override protected function configureTextDisplay():void {
    // skip
  }

  override protected function measure():void {
    super.measure();
    measuredHeight = Math.ceil(textDisplay.getPreferredBoundsHeight()) + border.contentInsets.height;
  }
}
}