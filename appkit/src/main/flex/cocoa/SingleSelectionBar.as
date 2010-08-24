package cocoa {
import cocoa.bar.Bar;
import cocoa.pane.PaneItem;

import spark.events.IndexChangeEvent;

use namespace ui;

[Abstract]
public class SingleSelectionBar extends Bar {
  private var typedSegmentedControl:SingleSelectionDataGroup;

  private var pendingSelectedIndex:int = 0;

  public function set selectedIndex(value:int):void {
    if (segmentedControl == null) {
      pendingSelectedIndex = value;
    }
    else {
      typedSegmentedControl.selectedIndex = value;
    }
  }

  public function get selectedItem():PaneItem {
    return PaneItem(items.getItemAt(typedSegmentedControl == null ? pendingSelectedIndex : typedSegmentedControl.selectedIndex));
  }

  override ui function segmentedControlAdded():void {
    typedSegmentedControl = SingleSelectionDataGroup(segmentedControl);
    typedSegmentedControl.selectedIndex = pendingSelectedIndex;
    pendingSelectedIndex = ListSelection.NO_SELECTION;

    segmentedControl.addEventListener(IndexChangeEvent.CHANGE, itemGroupSelectionChangeHandler);
  }

  ui function itemGroupRemoved():void {
    segmentedControl.removeEventListener(IndexChangeEvent.CHANGE, itemGroupSelectionChangeHandler);
  }

  protected function itemGroupSelectionChangeHandler(event:IndexChangeEvent):void {
    throw new Error("abstract");
  }
}
}