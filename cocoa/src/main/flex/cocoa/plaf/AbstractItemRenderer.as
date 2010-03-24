package cocoa.plaf
{
import cocoa.AbstractView;

import flash.text.engine.ElementFormat;

import spark.components.IItemRenderer;

public class AbstractItemRenderer extends AbstractView implements IItemRenderer
{
	protected var state:uint = 0;

	protected static const SELECTED:uint = 1 << 0;
	protected static const SHOWS_CARET:uint = 1 << 1;
	protected static const HIGHLIGHTED:uint = 1 << 3;

	protected var _laf:LookAndFeel;
	public function set laf(value:LookAndFeel):void
	{
		_laf = value;
	}

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

	public function set highlighted(value:Boolean):void
	{
		if (value == ((state & HIGHLIGHTED) == 0))
		{
			value ? state |= HIGHLIGHTED : state ^= HIGHLIGHTED;
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

	protected function getFont(key:String):ElementFormat
	{
		return _laf.getFont(key);
	}
}
}