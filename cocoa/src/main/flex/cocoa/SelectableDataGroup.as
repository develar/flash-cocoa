package cocoa
{
import cocoa.plaf.AbstractItemRenderer;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

import flash.events.MouseEvent;

import mx.core.IFlexDisplayObject;
import mx.core.IVisualElement;
import mx.core.mx_internal;

import spark.components.IItemRenderer;

use namespace mx_internal;

[Abstract]
public class SelectableDataGroup extends FlexDataGroup implements LookAndFeelProvider
{
	protected static const selectionChanged:uint = 1 << 0;
	private static const mouseSelectionModeChanged:uint = 1 << 1;

	protected var flags:uint = mouseSelectionModeChanged;

	public function SelectableDataGroup()
	{
		super();

		mouseEnabled = false;
	}

	private var _laf:LookAndFeel;
	public function get laf():LookAndFeel
	{
		return _laf;
	}
	public function set laf(value:LookAndFeel):void
	{
		_laf = value;
	}

	private var _iconFunction:Function;
	public function set iconFunction(value:Function):void
	{
		_iconFunction = value;
	}

	/**
	 * Only once before initial commitProperties.
	 */
	private var _mouseSelectionMode:int = ItemMouseSelectionMode.click;
	public function set mouseSelectionMode(value:int):void
	{
		if (value != _mouseSelectionMode)
		{
			_mouseSelectionMode = value;
		}
	}

	override protected function commitProperties():void
	{
		super.commitProperties();

		if (flags & mouseSelectionModeChanged)
		{
			flags ^= mouseSelectionModeChanged;
			if (_mouseSelectionMode != ItemMouseSelectionMode.none)
			{
				addEventListener(_mouseSelectionMode == ItemMouseSelectionMode.click ? MouseEvent.CLICK : MouseEvent.MOUSE_DOWN, itemMouseSelectHandler);
			}
		}

		if (flags & selectionChanged)
		{
			flags ^= selectionChanged;

			commitSelection();
		}
	}

	[Abstract]
	protected function commitSelection():void
	{

	}

	private function itemMouseSelectHandler(event:MouseEvent):void
    {
		if (event.target != this && event.target != parent)
		{
			itemSelecting(event.target is IItemRenderer ? IItemRenderer(event.target).itemIndex : getElementIndex(IVisualElement(event.target)));
			event.updateAfterEvent();
		}
	}

	protected function itemSelecting(itemIndex:int):void
    {

	}

	protected function itemSelected(index:int, selected:Boolean):void
	{
		var renderer:Object = getElementAt(index);
		if (renderer is IItemRenderer)
		{
			IItemRenderer(renderer).selected = selected;
		}
	}

	override public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void
    {
		super.updateRenderer(renderer, itemIndex, data);

		if (renderer is AbstractItemRenderer && _laf != null)
		{
			AbstractItemRenderer(renderer).laf = _laf;
		}
		if (renderer is IconedItemRenderer)
		{
			IconedItemRenderer(renderer).icon = itemToIcon(data);
		}
	}

	public function itemToIcon(item:Object):IFlexDisplayObject
    {
		return _iconFunction(item);
	}
}
}