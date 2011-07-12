package cocoa.plaf.basic {
import cocoa.Component;
import cocoa.Insets;
import cocoa.SegmentedControl;
import cocoa.Viewable;
import cocoa.layout.AdvancedLayout;
import cocoa.layout.ListHorizontalLayout;
import cocoa.plaf.Placement;
import cocoa.plaf.TabViewSkin;

import flash.display.DisplayObject;

import mx.core.ILayoutElement;
import mx.core.IUIComponent;

[Abstract]
public class AbstractTabViewSkin extends AbstractSkin implements AdvancedLayout, TabViewSkin {
  protected var tabBar:SegmentedControl;
  protected var contentView:IUIComponent;

  protected var tabBarPlacement:int;

  public function childCanSkipMeasurement(element:ILayoutElement):Boolean {
    // если у окна установлена фиксированный размер, то content pane устанавливается в размер невзирая на его preferred
    return canSkipMeasurement();
  }

  public function get contentInsets():Insets {
    throw new Error("abstract");
  }

  override protected function createChildren():void {
    super.createChildren();

    if (tabBar == null) {
      tabBar = new SegmentedControl();
      const tabBarLafKey:String = component.lafKey + ".tabBar";
      tabBar.lafKey = tabBarLafKey;
      var layout:ListHorizontalLayout = new ListHorizontalLayout();
      layout.gap = laf.getInt(tabBarLafKey + ".gap");
      tabBar.layout = layout;

      tabBarPlacement = laf.getInt(tabBarLafKey + ".placement");
      addChild(tabBar);
      component.uiPartAdded("segmentedControl", tabBar);
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
  
  public function hide():void {
    if (contentView != null) {
      removeChild(DisplayObject(contentView));
      contentView = null;
    }
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
    tabBar.setActualSize(w, tabBar.getExplicitOrMeasuredHeight());
    if (tabBarPlacement == Placement.PAGE_START_LINE_CENTER) {
      tabBar.x = Math.round((w - tabBar.getExplicitOrMeasuredWidth()) / 2);
    }

    if (contentView != null) {
      contentView.setActualSize(w - contentInsets.width, h - contentInsets.height);
    }
  }
}
}