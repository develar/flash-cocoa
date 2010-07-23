package cocoa
{
import cocoa.plaf.AbstractItemRenderer;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

import flash.events.MouseEvent;

import mx.core.IVisualElement;
import mx.core.mx_internal;

import mx.managers.IToolTipManagerClient;

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

	private var _lafSubname:String;
	public final function set lafSubname(value:String):void
	{
		_lafSubname = value;
	}

	private var _iconFunction:Function;
	public function set iconFunction(value:Function):void
	{
		_iconFunction = value;
	}

	private var _labelFunction:Function;
	public function set labelFunction(value:Function):void
	{
		_labelFunction = value;
	}

	private var _toolTipFunction:Function;
	public function set toolTipFunction(value:Function):void
	{
		_labelFunction = value;
	}

	/**
	 * Only once before initial commitProperties.
	 */
	private var _mouseSelectionMode:int = ItemMouseSelectionMode.CLICK;
	public function set mouseSelectionMode(value:int):void
	{
		if (value != _mouseSelectionMode)
		{
			_mouseSelectionMode = value;
		}
	}

	override protected function commitProperties():void
	{
		if (_lafSubname != null && itemRenderer == null)
		{
			itemRenderer = _laf.getFactory("SegmentedControl." + _lafSubname);
		}

		super.commitProperties();

		if (flags & mouseSelectionModeChanged)
		{
			flags ^= mouseSelectionModeChanged;
			if (_mouseSelectionMode != ItemMouseSelectionMode.NONE)
			{
				addEventListener(_mouseSelectionMode == ItemMouseSelectionMode.CLICK ? MouseEvent.CLICK : MouseEvent.MOUSE_DOWN, itemMouseSelectHandler);
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

		if (_toolTipFunction != null && renderer is IToolTipManagerClient)
		{
			IToolTipManagerClient(renderer).toolTip = _toolTipFunction(data);
		}
	}

	private function itemToIcon(item:Object):Icon
    {
		return _iconFunction(item);
	}

	override public function itemToLabel(item:Object):String
	{
		return _labelFunction == null ? super.itemToLabel(item) : _labelFunction(item);
	}

	override protected function initializationComplete():void
	{
		super.initializationComplete();
	}
}
}