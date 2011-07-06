package cocoa.sidebar {
import cocoa.Panel;
import cocoa.ViewContainer;
import cocoa.bar.Bar;
import cocoa.pane.PaneItem;
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

  private var pendingSelectedIndices:Vector.<int>;

  public function set selectedIndices(value:Vector.<int>):void {
    if (segmentedControl == null) {
      pendingSelectedIndices = value;
    }
    else {
      segmentedControl.selectedIndices = value;
    }
  }

  override ui function segmentedControlAdded():void {
    segmentedControl.selectedIndices = pendingSelectedIndices;
    pendingSelectedIndices = null;

    segmentedControl.selectionChanged.add(paneLabelBarSelectionChanged);
  }

  ui function paneGroupAdded():void {
    paneGroup.includeInLayout = !collapsed;
  }

  private function paneLabelBarSelectionChanged(added:Vector.<int>, removed:Vector.<int>):void {
    if (removed != null) {
      showPanes(removed, false);
    }
    if (added != null) {
      showPanes(added, true);
    }

    if (collapsed != isEmpty(segmentedControl.selectedIndices)) {
      collapsed = !collapsed;

      skin.invalidateSize();

      paneGroup.includeInLayout = !collapsed;
    }
  }

  public static function isEmpty(v:Vector.<int>):Boolean {
    return v == null || v.length == 0;
  }

  private function showPanes(indices:Vector.<int>, show:Boolean):void {
    for each (var index:int in indices) {
      showPane(PaneItem(dataSource.getObjectValue(index)), show);
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

    pane.paneHid.add(hidePaneHandler);
    pane.sideHid.add(hideSideHandler);

    if (paneGroup != null) {
      paneGroup.addSubview(pane);
    }
  }

  private function hidePaneHandler(pane:Panel):void {
    assert(!pane.hidden);
    segmentedControl.setSelected(paneGroup.getSubviewIndex(pane), false);
  }

  private function hideSideHandler():void {
    selectedIndices = null;
  }

  override protected function get primaryLaFKey():String {
    return "Sidebar";
  }
}
}