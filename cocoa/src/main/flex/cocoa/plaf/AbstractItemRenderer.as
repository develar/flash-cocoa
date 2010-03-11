package cocoa.plaf
{
import flash.events.MouseEvent;

import mx.core.UIComponent;

import spark.components.IItemRenderer;

public class AbstractItemRenderer extends UIComponent implements IItemRenderer
{
	protected var state:uint = 0;

	public static const SELECTED:uint = 1 << 0;
	public static const SHOWS_CARET:uint = 1 << 1;
	public static const HOVERED:uint = 1 << 2;

	private var _itemIndex:int;
	public function get itemIndex():int
	{
		return _itemIndex;
	}
	public function set itemIndex(value:int):void
	{ 
		if (value != _itemIndex)
		{
			_itemIndex = value;
			invalidateDisplayList();
		}
	}

	public function get dragging():Boolean
	{
		return false;
	}
	public function set dragging(value:Boolean):void
	{
	}

	public function get label():String
	{
		return null;
	}
	public function set label(value:String):void
	{
	}

	public function get selected():Boolean
	{
		return (state & SELECTED) != 0;
	}
	public function set selected(value:Boolean):void
	{
		if (value == ((state & SELECTED) == 0))
		{
			value ? state |= SELECTED : state ^= SELECTED;
			invalidateDisplayList();
		}
	}

	public function get showsCaret():Boolean
	{
		return (state & SHOWS_CARET) != 0;
	}

	public function set showsCaret(value:Boolean):void
	{
		if (value == ((state & SHOWS_CARET) == 0))
		{
			value ? state |= SHOWS_CARET : state ^= SHOWS_CARET;
			invalidateDisplayList();
		}
	}

	public function get data():Object
	{
		return null;
	}
	public function set data(value:Object):void
	{
	}

	protected function addRollHandlers():void
	{
		addEventListener(MouseEvent.ROLL_OVER, rollOverHandler);
		addEventListener(MouseEvent.ROLL_OUT, rollOutHandler);
	}

	private function rollOverHandler(event:MouseEvent):void
	{
		state |= HOVERED;
		invalidateDisplayList();
	}

	private function rollOutHandler(event:MouseEvent):void
	{
		state ^= HOVERED;
		invalidateDisplayList();
	}
}
}