package cocoa
{
import cocoa.bar.Bar;
import cocoa.pane.PaneItem;

import spark.events.IndexChangeEvent;

use namespace ui;

[Abstract]
public class SingleSelectionBar extends Bar
{
	protected var typedItemGroup:SingleSelectionDataGroup;

	private var pendingSelectedIndex:int = 0;
	public function set selectedIndex(value:int):void
	{
		if (segmentedControl == null)
		{
			pendingSelectedIndex = value;
		}
		else
		{
			typedItemGroup.selectedIndex = value;
		}
	}

	public function get selectedItem():PaneItem
	{
		return PaneItem(items.getItemAt(typedItemGroup == null ? pendingSelectedIndex : typedItemGroup.selectedIndex));
	}

	override ui function segmentedControlAdded():void
	{
		typedItemGroup = SingleSelectionDataGroup(segmentedControl);
		typedItemGroup.selectedIndex = pendingSelectedIndex;
		pendingSelectedIndex = -1;

		segmentedControl.addEventListener(IndexChangeEvent.CHANGE, itemGroupSelectionChangeHandler);
	}

	ui function itemGroupRemoved():void
	{
		segmentedControl.removeEventListener(IndexChangeEvent.CHANGE, itemGroupSelectionChangeHandler);
	}

	protected function itemGroupSelectionChangeHandler(event:IndexChangeEvent):void
	{
		throw new Error("abstract");
	}
}
}