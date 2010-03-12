package cocoa
{
import mx.core.mx_internal;

import spark.components.supportClasses.ListBase;
import spark.events.IndexChangeEvent;

use namespace mx_internal;

public class SingleSelectionDataGroup extends SelectableDataGroup
{
	private var proposedSelectedIndex:int = ListBase.NO_SELECTION;

	private var _selectedIndex:int = ListBase.NO_SELECTION;
	public function get selectedIndex():int
	{
		return _selectedIndex;
	}
	public function set selectedIndex(value:int):void
	{
		if (value == selectedIndex)
		{
			return;
		}

		proposedSelectedIndex = value;
		selectionChanged = true;

		invalidateProperties();
	}

	override protected function itemSelecting(itemIndex:int):void
    {
		if (itemIndex != _selectedIndex)
		{
			adjustSelection(_selectedIndex, itemIndex);
		}
    }

	private function adjustSelection(oldIndex:int, newIndex:int):void
	{
		_selectedIndex = newIndex;

		if (oldIndex != ListBase.NO_SELECTION)
		{
			itemSelected(oldIndex, false);
		}
		itemSelected(newIndex, true);

		dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE, false, false, oldIndex, newIndex));
	}

	override protected function commitSelection():void
	{
		var oldIndex:int = _selectedIndex;
		_selectedIndex = proposedSelectedIndex;
		proposedSelectedIndex = -1;

		adjustSelection(oldIndex, _selectedIndex);
	}

	override mx_internal function itemRemoved(item:Object, index:int):void
    {
		if (selectedIndex == index || selectedIndex >= dataProvider.length)
		{
			selectedIndex = 0;
		}

		super.itemRemoved(item, index);
	}
}
}