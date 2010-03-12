package cocoa
{
import org.flyti.view.*;
import org.flyti.view;
import cocoa.bar.Bar;
import org.flyti.view.pane.PaneItem;

import spark.events.IndexChangeEvent;

use namespace view;

[Abstract]
public class SingleSelectionBar extends Bar
{
	protected var typedItemGroup:SingleSelectionDataGroup;

	private var pendingSelectedIndex:int = 0;
	public function set selectedIndex(value:int):void
	{
		if (itemGroup == null)
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

	override view function itemGroupAdded():void
	{
		super.itemGroupAdded();

		typedItemGroup = SingleSelectionDataGroup(itemGroup);
		typedItemGroup.selectedIndex = pendingSelectedIndex;
		pendingSelectedIndex = -1;

		itemGroup.addEventListener(IndexChangeEvent.CHANGE, itemGroupSelectionChangeHandler);
	}

	view function itemGroupRemoved():void
	{
		itemGroup.removeEventListener(IndexChangeEvent.CHANGE, itemGroupSelectionChangeHandler);
	}

	protected function itemGroupSelectionChangeHandler(event:IndexChangeEvent):void
	{
		throw new Error("abstract");
	}
}
}