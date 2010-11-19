package cocoa.plaf.basic {
import cocoa.Insets;
import cocoa.SingleSelectionDataGroup;
import cocoa.ViewStack;
import cocoa.layout.AdvancedLayout;
import cocoa.layout.SegmentedControlHorizontalLayout;
import cocoa.plaf.Placement;

import mx.core.ILayoutElement;

[Abstract]
public class AbstractTabViewSkin extends AbstractSkin implements AdvancedLayout {
  protected var segmentedControl:SingleSelectionDataGroup;
  protected var viewStack:ViewStack;

  protected var segmentedControlPlacement:int;

  public function childCanSkipMeasurement(element:ILayoutElement):Boolean {
    // если у окна установлена фиксированный размер, то content pane устанавливается в размер невзирая на его preferred
    return canSkipMeasurement();
  }

  protected function get contentInsets():Insets {
    throw new Error("abstract");
  }

  override protected function createChildren():void {
    super.createChildren();

    if (viewStack == null) {
      viewStack = new ViewStack();
      viewStack.laf = laf;
      viewStack.move(contentInsets.left, contentInsets.top);
      addChild(viewStack);
      component.uiPartAdded("viewStack", viewStack);
    }

    if (segmentedControl == null) {
      segmentedControl = new SingleSelectionDataGroup();
      var layout:SegmentedControlHorizontalLayout = new SegmentedControlHorizontalLayout();
      layout.gap = 1;
      layout.useGapForEdge = true;
      segmentedControl.layout = layout;
      segmentedControl.laf = laf;
      segmentedControl.lafSubkey = component.lafKey + ".segmentedControl";
      SegmentedControlController(laf.getFactory(component.lafKey + ".segmentedControlController").newInstance()).register(segmentedControl);

      segmentedControlPlacement = int(laf.getObject(segmentedControl.lafSubkey + ".placement"));
      addChild(segmentedControl);
      component.uiPartAdded("segmentedControl", segmentedControl);
    }
  }

  override protected function measure():void {
    measuredMinWidth = viewStack.minWidth + contentInsets.width;
    measuredMinHeight = viewStack.minHeight + contentInsets.height;

    measuredWidth = viewStack.getExplicitOrMeasuredWidth() + contentInsets.width;
    measuredHeight = viewStack.getExplicitOrMeasuredHeight() + contentInsets.height;
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    segmentedControl.setLayoutBoundsSize(NaN, NaN);
    if (segmentedControlPlacement == Placement.PAGE_START_LINE_CENTER) {
      segmentedControl.x = Math.round((w - segmentedControl.getExplicitOrMeasuredWidth()) / 2);
    }

    if (viewStack.includeInLayout) {
      viewStack.setActualSize(w - contentInsets.width, h - contentInsets.height);
    }
  }
}
}