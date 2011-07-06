package cocoa {
import cocoa.bar.Bar;
import cocoa.pane.PaneItem;

import spark.events.IndexChangeEvent;

use namespace ui;

[Abstract]
public class SingleSelectionBar extends Bar {
  private var pendingSelectedIndex:int = 0;

  public function set selectedIndex(value:int):void {
    if (segmentedControl == null) {
      pendingSelectedIndex = value;
    }
    else {
      segmentedControl.selectedIndex = value;
    }
  }

  public function get selectedItem():PaneItem {
    return dataSource == null || dataSource.itemCount == 0 ? null : PaneItem(dataSource.getObjectValue(segmentedControl == null ? pendingSelectedIndex : segmentedControl.selectedIndex));
  }

  override ui function segmentedControlAdded():void {
    segmentedControl.selectionChanged.add(segmentedControlSelectionChanged);
  }

  ui function itemGroupRemoved():void {
    segmentedControl.removeEventListener(IndexChangeEvent.CHANGE, segmentedControlSelectionChanged);
  }

  protected function segmentedControlSelectionChanged(oldIndex:int, newIndex:int):void {
    throw new Error("abstract");
  }

  override protected function validateItems():void {
    super.validateItems();

    if (pendingSelectedIndex == 0 && !dataSource.empty) {
      segmentedControl.selectedIndex = pendingSelectedIndex;
      pendingSelectedIndex = -1;
    }
  }
}
}