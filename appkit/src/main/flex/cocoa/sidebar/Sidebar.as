package cocoa.sidebar {
import cocoa.Panel;
import cocoa.ViewContainer;
import cocoa.bar.Bar;
import cocoa.pane.PaneItem;
import cocoa.sidebar.events.MultipleSelectionChangeEvent;
import cocoa.sidebar.events.SidebarEvent;
import cocoa.ui;

import flash.utils.Dictionary;

use namespace ui;

public class Sidebar extends Bar {
  private static const _skinParts:Dictionary = new Dictionary();
  _cl(_skinParts, Bar._skinParts);
  _skinParts.paneGroup = HANDLER_NOT_EXISTS;
  override protected function get skinParts():Dictionary {
    return _skinParts;
  }

  ui var paneGroup:ViewContainer;

  private var collapsed:Boolean = true;
  private var typedPaneLabelBar:SidebarPaneLabelBar;

  private var pendingSelectedIndices:Vector.<int>;

  public function set selectedIndices(value:Vector.<int>):void {
    if (segmentedControl == null) {
      pendingSelectedIndices = value;
    }
    else {
      typedPaneLabelBar.selectedIndices = value;
    }
  }

  override ui function segmentedControlAdded():void {
    typedPaneLabelBar = SidebarPaneLabelBar(segmentedControl);
    typedPaneLabelBar.selectedIndices = pendingSelectedIndices;
    pendingSelectedIndices = null;

    segmentedControl.addEventListener(MultipleSelectionChangeEvent.CHANGED, paneLabelBarSelectionChangeHandler);
  }

  ui function paneGroupAdded():void {
    paneGroup.includeInLayout = !collapsed;
  }

  private function paneLabelBarSelectionChangeHandler(event:MultipleSelectionChangeEvent):void {
    if (event.removed != null) {
      showPanes(event.removed, false);
    }
    if (event.added != null) {
      showPanes(event.added, true);
    }

    if (collapsed != isEmpty(typedPaneLabelBar.selectedIndices)) {
      collapsed = !collapsed;

      skin.invalidateSize();

      paneGroup.includeInLayout = !collapsed;
    }
  }

  private function isEmpty(v:Vector.<int>):Boolean {
    return v == null || v.length == 0;
  }

  private function showPanes(indices:Vector.<int>, show:Boolean):void {
    for each (var index:int in indices) {
      showPane(PaneItem(items.getItemAt(index)), show);
    }
  }

  private function showPane(paneMetadata:PaneItem, show:Boolean):void {
    if (paneMetadata.view == null) {
      createPaneView(paneMetadata);
    }
    Panel(paneMetadata.view).hidden = !show;
  }

  private function createPaneView(paneMetadata:PaneItem):void {
    assert(paneMetadata.view == null);

    var pane:Panel = paneMetadata.viewFactory.newInstance();
    paneMetadata.view = pane;

    pane.title = paneMetadata.localizedTitle;

    pane.addEventListener(SidebarEvent.HIDE_PANE, hidePaneHandler);
    pane.addEventListener(SidebarEvent.HIDE_SIDE, hideSideHandler);

    if (paneGroup != null) {
      paneGroup.addSubview(pane);
    }
  }

  private function hidePaneHandler(event:SidebarEvent):void {
    var pane:Panel = Panel(event.currentTarget);
    assert(!pane.hidden);
    typedPaneLabelBar.adjustSelectionIndices(paneGroup.getSubviewIndex(pane), false);
  }

  private function hideSideHandler(event:SidebarEvent):void {
    selectedIndices = null;
  }

  override protected function get primaryLaFKey():String {
    return "Sidebar";
  }
}
}