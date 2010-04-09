package cocoa
{
import flash.utils.Dictionary;

import org.flyti.util.List;

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
		itemGroup.mouseSelectionMode = ItemMouseSelectionMode.NONE; // delegate to MenuController (see PopUpMenuController)
	}

	private var pendingSelectedIndex:int = 0;
	public function get selectedIndex():int
	{
		return itemGroup == null ? pendingSelectedIndex : itemGroup.selectedIndex;
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
		return _items.empty ? null : _items.getItemAt(itemGroup == null ? pendingSelectedIndex : itemGroup.selectedIndex);
	}
	public function set selectedItem(value:Object):void
	{
		selectedIndex = _items.getItemIndex(value);
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
	private var _items:List;
	public function set items(value:List):void
	{
		if (value != _items)
		{
			_items = value;
			itemsChanged = true;
			invalidateProperties();
		}
	}

	public function get numberOfItems():int
	{
		return _items.length;
	}

	override protected function get defaultLaFPrefix():String
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