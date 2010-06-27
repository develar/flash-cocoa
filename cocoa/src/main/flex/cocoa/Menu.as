package cocoa
{
import flash.events.Event;
import flash.utils.Dictionary;

import mx.events.CollectionEvent;

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
		return _items.empty || (itemGroup != null && itemGroup.selectedIndex == ListSelection.NO_SELECTION) ? null : _items.getItemAt(itemGroup == null ? pendingSelectedIndex : itemGroup.selectedIndex);
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
			var dispatchChangeEvent:Boolean = _items != null;
			if (_items != null)
			{
				_items.removeEventListener(CollectionEvent.COLLECTION_CHANGE, itemsChangeHandler);
			}
			_items = value;
			itemsChanged = true;
			invalidateProperties();

			if (dispatchChangeEvent)
			{
				itemsChangeHandler();
			}
		}
	}

	private function itemsChangeHandler(event:CollectionEvent = null):void
	{
		AbstractView(skin).callLater(dispatchChangeEvent);
	}

	private function dispatchChangeEvent():void
	{
		dispatchEvent(new Event(Event.CHANGE));
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
			pendingSelectedIndex = ListSelection.NO_SELECTION;

			_items.addEventListener(CollectionEvent.COLLECTION_CHANGE, itemsChangeHandler, false, -1 /* after itemGroup handler */);
		}
	}
}
}