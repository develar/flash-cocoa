package cocoa.bar {
import cocoa.pane.PaneItem;
import cocoa.ui;

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
    return dataSource == null || dataSource.itemCount == 0 || segmentedControl.selectedIndex == -1 ? null : PaneItem(dataSource.getObjectValue(segmentedControl == null ? pendingSelectedIndex : segmentedControl.selectedIndex));
  }
  
  public function set selectedItem(value:PaneItem):void {
    selectedIndex = value == null ? -1 : dataSource.getItemIndex(value);
  }

  override ui function segmentedControlAdded():void {
    super.segmentedControlAdded();

    segmentedControl.selectionChanged.add(segmentedControlSelectionChanged);
  }

  ui function itemGroupRemoved():void {
    segmentedControl.selectionChanged.remove(segmentedControlSelectionChanged);
  }

  protected function segmentedControlSelectionChanged(oldItem:PaneItem, newItem:PaneItem, oldIndex:int, newIndex:int):void {
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