package cocoa.plaf.basic {
import cocoa.Component;
import cocoa.Insets;
import cocoa.SingleSelectionDataGroup;
import cocoa.Viewable;
import cocoa.layout.AdvancedLayout;
import cocoa.layout.SegmentedControlHorizontalLayout;
import cocoa.plaf.Placement;
import cocoa.plaf.TabViewSkin;

import flash.display.DisplayObject;

import mx.core.ILayoutElement;
import mx.core.IUIComponent;

[Abstract]
public class AbstractTabViewSkin extends AbstractSkin implements AdvancedLayout, TabViewSkin {
  protected var segmentedControl:SingleSelectionDataGroup;
  protected var contentView:IUIComponent;

  protected var segmentedControlPlacement:int;

  public function childCanSkipMeasurement(element:ILayoutElement):Boolean {
    // если у окна установлена фиксированный размер, то content pane устанавливается в размер невзирая на его preferred
    return canSkipMeasurement();
  }

  public function get contentInsets():Insets {
    throw new Error("abstract");
  }

  override protected function createChildren():void {
    super.createChildren();

    if (segmentedControl == null) {
      segmentedControl = new SingleSelectionDataGroup();
      var layout:SegmentedControlHorizontalLayout = new SegmentedControlHorizontalLayout();
      layout.useGapForEdge = true;
      segmentedControl.layout = layout;
      segmentedControl.laf = laf;
      segmentedControl.lafSubkey = component.lafKey + ".segmentedControl";
      SegmentedControlController(laf.getFactory(component.lafKey + ".segmentedControlController").newInstance()).register(segmentedControl);

      layout.gap = int(laf.getObject(segmentedControl.lafSubkey + ".gap"));
      segmentedControlPlacement = int(laf.getObject(segmentedControl.lafSubkey + ".placement"));
      addChild(segmentedControl);
      component.uiPartAdded("segmentedControl", segmentedControl);
    }
  }

  public function show(viewable:Viewable):void {
    if (contentView != null) {
      removeChild(DisplayObject(contentView));
    }

    if (viewable is Component) {
      var component:Component = Component(viewable);
      contentView = component.skin == null ? component.createView(laf) : component.skin;
    }
    else {
      contentView = IUIComponent(viewable);
    }

    contentView.move(contentInsets.left, contentInsets.top);
    addChild(DisplayObject(contentView));
  }

  override protected function measure():void {
    if (contentView == null) {
      super.measure();
      return;
    }

    measuredMinWidth = contentView.minWidth + contentInsets.width;
    measuredMinHeight = contentView.minHeight + contentInsets.height;

    measuredWidth = contentView.getExplicitOrMeasuredWidth() + contentInsets.width;
    measuredHeight = contentView.getExplicitOrMeasuredHeight() + contentInsets.height;
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    segmentedControl.setLayoutBoundsSize(NaN, NaN);
    if (segmentedControlPlacement == Placement.PAGE_START_LINE_CENTER) {
      segmentedControl.x = Math.round((w - segmentedControl.getExplicitOrMeasuredWidth()) / 2);
    }

    if (contentView != null) {
      contentView.setActualSize(w - contentInsets.width, h - contentInsets.height);
    }
  }
}
}