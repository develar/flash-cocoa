package cocoa
{
import flash.utils.Dictionary;

import mx.collections.IList;

use namespace ui;

public class Menu extends AbstractComponent
{
	protected static const _skinParts:Dictionary = new Dictionary();
	_skinParts.itemGroup = 0;
	override protected function get skinParts():Dictionary
	{
		return _skinParts;
	}

	ui var itemGroup:SingleSelectionDataGroup;

	ui function itemGroupAdded():void
	{

	}

	private var pendingSelectedIndex:int = 0;
	public function get selectedIndex():int
	{
		return itemGroup.selectedIndex;
	}
	public function set selectedIndex(value:int):void
	{
		if (itemGroup == null)
		{
			pendingSelectedIndex = value;
		}
		else
		{
			itemGroup.selectedIndex = value;
		}
	}

	public function get selectedItem():Object
	{
		return _items.getItemAt(itemGroup == null ? pendingSelectedIndex : itemGroup.selectedIndex);
	}

	private var _labelFunction:Function;
	public function get labelFunction():Function
	{
		return _labelFunction;
	}
	public function set labelFunction(labelFunction:Function):void
	{
		_labelFunction = labelFunction;
	}

	private var itemsChanged:Boolean;
	private var _items:IList;
	public function set items(value:IList):void
	{
		if (value != _items)
		{
			_items = value;
			itemsChanged = true;
			invalidateProperties();
		}
	}

	override public function get lafPrefix():String
	{
		return "Menu";
	}

	override public function commitProperties():void
	{
		super.commitProperties();

		if (itemsChanged)
		{
			itemsChanged = false;
			itemGroup.dataProvider = _items;
			itemGroup.selectedIndex = pendingSelectedIndex;
			pendingSelectedIndex = -1;
		}
	}
}
}