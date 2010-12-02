package cocoa.plaf.aqua {
import cocoa.Insets;
import cocoa.layout.SegmentedControlHorizontalLayout;
import cocoa.plaf.basic.AbstractTabViewSkin;

public class BorderlessTabViewSkin extends AbstractTabViewSkin {
  private static const CONTENT_INSETS:Insets = new Insets(0, 29, 0, 0);

  override public function get contentInsets():Insets {
    return CONTENT_INSETS;
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    segmentedControl.setLayoutBoundsSize(w, NaN);
    var segmentCount:int = segmentedControl.dataProvider.length;
    SegmentedControlHorizontalLayout(segmentedControl.layout).itemWidth = Math.round((w - (segmentCount + 1 /* gap */)) / segmentCount);

    viewStack.setActualSize(w - contentInsets.width, h - contentInsets.height);
  }
}
}