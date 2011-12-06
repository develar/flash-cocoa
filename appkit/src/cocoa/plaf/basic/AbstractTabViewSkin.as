package cocoa.plaf.basic {
import cocoa.SkinnableView;
import cocoa.Insets;
import cocoa.SegmentedControl;
import cocoa.View;
import cocoa.plaf.Placement;
import cocoa.plaf.TabViewSkin;

import flash.display.DisplayObject;

import mx.core.ILayoutElement;
import mx.core.IUIComponent;

[Abstract]
public class AbstractTabViewSkin extends AbstractSkin implements TabViewSkin {
  protected var tabBar:SegmentedControl;
  protected var contentView:View;

  protected var tabBarPlacement:int;

  public function get contentInsets():Insets {
    throw new Error("abstract");
  }

  override protected function createChildren():void {
    super.createChildren();

    if (tabBar == null) {
      tabBar = new SegmentedControl();
      const tabBarLafKey:String = hostComponent.lafKey + ".tabBar";
      tabBar.lafKey = tabBarLafKey;

      tabBarPlacement = laf.getInt(tabBarLafKey + ".placement");
      addChild(tabBar);
      hostComponent.uiPartAdded("segmentedControl", tabBar);
    }
  }

  public function show(viewable:View):void {
    if (contentView != null) {
      removeChild(DisplayObject(contentView));
    }

    if (viewable is SkinnableView) {
      var component:SkinnableView = SkinnableView(viewable);
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