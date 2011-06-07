package cocoa.sidebar {
import cocoa.Panel;
import cocoa.SelectableDataGroup;
import cocoa.pane.PaneItem;
import cocoa.sidebar.events.MultipleSelectionChangeEvent;

public class SidebarPaneLabelBar extends SelectableDataGroup {
  private var proposedSelectedIndices:Vector.<int>;

  private var _selectedIndices:Vector.<int>;
  public function get selectedIndices():Vector.<int> {
    return _selectedIndices;
  }

  public function set selectedIndices(value:Vector.<int>):void {
    if (value == selectedIndices) {
      return;
    }

    proposedSelectedIndices = value;
    flags |= selectionChanged;

    invalidateProperties();
  }

  override protected function commitSelection():void {
    var addedItems:Vector.<int> = new Vector.<int>();
    var removedItems:Vector.<int> = new Vector.<int>();
    var i:int;
    var n:int;

    if (!Sidebar.isEmpty(selectedIndices)) {
      if (Sidebar.isEmpty(proposedSelectedIndices)) {
        // Going to a null selection, remove all
        removedItems = _selectedIndices;
      }
      else {
        // Changing selection, determine which items were added to the selection interval
        n = proposedSelectedIndices.length;
        for (i = 0; i < n; i++) {
          if (selectedIndices.indexOf(proposedSelectedIndices[i]) == -1) {
            addedItems.push(proposedSelectedIndices[i]);
          }
        }
        // Then determine which items were removed from the selection interval
        n = selectedIndices.length;
        for (i = 0; i < n; i++) {
          if (proposedSelectedIndices.indexOf(selectedIndices[i]) == -1) {
            removedItems.push(selectedIndices[i]);
          }
        }
      }
    }
    else if (!Sidebar.isEmpty(proposedSelectedIndices)) {
      // Going from a null selection, add all
      addedItems = proposedSelectedIndices;
    }

    for (i = 0,n = addedItems.length; i < n; i++) {
      itemSelected(addedItems[i], true);
    }
    for (i = 0,n = removedItems.length; i < n; i++) {
      itemSelected(removedItems[i], false);
    }

    _selectedIndices = proposedSelectedIndices;
    proposedSelectedIndices = null;

    dispatchEvent(new MultipleSelectionChangeEvent(addedItems, removedItems));
  }

  override public function itemSelecting(itemIndex:int):void {
    var paneMetadata:PaneItem = PaneItem(dataProvider.getItemAt(itemIndex));
    var pane:Panel = Panel(paneMetadata.view);
    var wasHidden:Boolean = pane == null || pane.hidden;
    adjustSelectionIndices(itemIndex, wasHidden);
  }

  public function adjustSelectionIndices(paneIndex:int, selected:Boolean):void {
    if (Sidebar.isEmpty(selectedIndices)) {
      assert(selected);
      _selectedIndices = new <int>[paneIndex];
    }
    else {
      var newSelectedIndices:Vector.<int> = selectedIndices.slice();
      var currentSelectionIndex:int = selectedIndices.indexOf(paneIndex);
      if (selected) {
        assert(currentSelectionIndex == -1);
        newSelectedIndices.push(paneIndex);
      }
      else {
        assert(currentSelectionIndex != -1);
        newSelectedIndices.splice(currentSelectionIndex, 1);
      }

      _selectedIndices = newSelectedIndices;
    }

    itemSelected(paneIndex, selected);

    var eventIndices:Vector.<int> = new <int>[paneIndex];
    dispatchEvent(new MultipleSelectionChangeEvent(selected ? eventIndices : null, selected ? null : eventIndices));
  }
}
}