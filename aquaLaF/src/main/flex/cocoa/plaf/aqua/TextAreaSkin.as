package cocoa.plaf.aqua {
import cocoa.ScrollPolicy;
import cocoa.ScrollView;
import cocoa.View;

public class TextAreaSkin extends TextInputSkin {
  private var scroller:ScrollView;

  override protected function get documentView():View {
    return scroller;
  }

  override protected function configureAndAddTextDisplay():void {
    scroller = new ScrollView();
    scroller.horizontalScrollPolicy = ScrollPolicy.OFF;
    scroller.verticalScrollPolicy = ScrollPolicy.ON;
    scroller.documentView = textDisplay;
    addChild(scroller);
  }

  override protected function measure():void {
    super.measure();
    measuredHeight = Math.ceil(textDisplay.getPreferredBoundsHeight()) + border.contentInsets.height;
  }
}
}