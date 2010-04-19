package cocoa
{
import mx.core.mx_internal;

import spark.events.IndexChangeEvent;

use namespace mx_internal;

public class SingleSelectionDataGroup extends SelectableDataGroup
{
	private var oldSelectedIndex:int = ListSelection.NO_SELECTION;

	private var _selectedIndex:int = ListSelection.NO_SELECTION;
	public function get selectedIndex():int
	{
		return _selectedIndex;
	}
	public function set selectedIndex(value:int):void
	{
		if (value == _selectedIndex)
		{
			return;
		}

		oldSelectedIndex = _selectedIndex;
		_selectedIndex = value;
		flags |= selectionChanged;

		invalidateProperties();
	}

	override protected function itemSelecting(itemIndex:int):void
    {
		if (itemIndex != _selectedIndex)
		{
			oldSelectedIndex = _selectedIndex;
			_selectedIndex = itemIndex;
			adjustSelection();
		}
    }

	private function adjustSelection():void
	{
		if (oldSelectedIndex != ListSelection.NO_SELECTION)
		{
			itemSelected(oldSelectedIndex, false);
		}
		if (_selectedIndex != ListSelection.NO_SELECTION)
		{
			itemSelected(_selectedIndex, true);
		}

		dispatchEvent(new IndexChangeEvent(IndexChangeEvent.CHANGE, false, false, oldSelectedIndex, _selectedIndex));

		oldSelectedIndex = ListSelection.NO_SELECTION;
	}

	override protected function commitSelection():void
	{
		adjustSelection();
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