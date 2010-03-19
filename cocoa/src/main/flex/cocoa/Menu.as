package cocoa
{
import flash.utils.Dictionary;

import mx.collections.IList;

import spark.components.DataGroup;

use namespace ui;

public class Menu extends AbstractComponent
{
	protected static const _skinParts:Dictionary = new Dictionary();
	_skinParts.itemGroup = 0;
	override protected function get skinParts():Dictionary
	{
		return _skinParts;
	}

	ui var itemGroup:DataGroup;

	ui function itemGroupAdded():void
	{
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

	override public function commitProperties():void
	{
		super.commitProperties();

		if (itemsChanged)
		{
			itemsChanged = false;
			if (itemGroup != null)
			{
				itemGroup.dataProvider = _items;
			}
		}
	}

	override public function get lafPrefix():String
	{
		return "Menu";
	}
}
}