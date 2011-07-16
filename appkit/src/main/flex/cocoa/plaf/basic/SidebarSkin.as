package cocoa.plaf.basic {
import cocoa.Container;
import cocoa.SegmentedControl;
import cocoa.SelectionMode;
import cocoa.sidebar.SidebarLayout;

public class SidebarSkin extends AbstractSkin {
  private var tabBar:SegmentedControl;
  private var paneGroup:Container;

  override protected function createChildren():void {
    super.createChildren();

    if (tabBar == null) {
      tabBar = new SegmentedControl();
      tabBar.mode = SelectionMode.ANY;
      tabBar.lafKey = component.lafKey +  ".tabBar";

      addChild(tabBar);
      component.uiPartAdded("segmentedControl", tabBar);
    }

    if (paneGroup == null) {
      paneGroup = new Container();
      var sidebarLayout:SidebarLayout = new SidebarLayout();
      sidebarLayout.gap = 7;
      paneGroup.layout = sidebarLayout;
      paneGroup.x = -1; // idea sidebar: if open, overlap editor tab right border, 1px.
      addChild(paneGroup);
      component.uiPartAdded("paneGroup", paneGroup);
    }
  }

  override protected function measure():void {
    measuredWidth = paneGroup.includeInLayout ? ((492 - 1 /* idea sidebar: if open, overlap editor tab right border, 1px */) + 25) : 25;
    measuredHeight = 0;

    measuredMinWidth = 25;
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    tabBar.setActualSize(20, h);
    tabBar.x = w - 2 - 20;

    if (paneGroup.includeInLayout) {
      paneGroup.setLayoutBoundsSize(w - 24, h);
    }
  }
}
}