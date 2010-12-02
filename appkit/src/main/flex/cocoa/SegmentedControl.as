package cocoa {
import cocoa.layout.SegmentedControlHorizontalLayout;
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.basic.SegmentedControlController;

public class SegmentedControl extends SingleSelectionDataGroup {
  override protected function createChildren():void {
    if (layout == null) {
      layout = new SegmentedControlHorizontalLayout();
    }

    laf = LookAndFeelUtil.find(parent);
    SegmentedControlController(laf.getFactory((lafSubkey == null ? "SegmentedControl" : lafSubkey) + ".segmentedControlController").newInstance()).register(this);
    if (lafSubkey == null && itemRenderer == null) {
      itemRenderer = laf.getFactory("SegmentedControl.iR");
    }

    super.createChildren();
  }
}
}