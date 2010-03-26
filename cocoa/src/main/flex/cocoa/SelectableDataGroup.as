package cocoa
{
import cocoa.layout.LayoutMetrics;
import cocoa.plaf.AbstractItemRenderer;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;

import mx.core.IFlexDisplayObject;
import mx.core.IVisualElement;
import mx.core.mx_internal;

import spark.components.DataGroup;
import spark.components.IItemRenderer;

use namespace mx_internal;

[Abstract]
public class SelectableDataGroup extends DataGroup implements LookAndFeelProvider
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

	// disable unwanted legacy
	override public function regenerateStyleCache(recursive:Boolean):void
	{

	}

	override public function styleChanged(styleProp:String):void
    {

	}

	override protected function resourcesChanged():void
    {

	}

	override public function get layoutDirection():String
    {
		return AbstractView.LAYOUT_DIRECTION_LTR;
	}

	override public function registerEffects(effects:Array /* of String */):void
    {

	}

	override mx_internal function initThemeColor():Boolean
    {
		return true;
	}

	private var layoutMetrics:LayoutMetrics;

	override public function getConstraintValue(constraintName:String):*
    {
		if (layoutMetrics == null)
		{
			return undefined;
		}
		else
		{
			var value:Number = layoutMetrics[constraintName];
			return isNaN(value) ? undefined : value;
		}
	}

	override public function setConstraintValue(constraintName:String, value:*):void
    {
		if (layoutMetrics == null)
		{
			layoutMetrics = new LayoutMetrics();
		}

		layoutMetrics[constraintName] = value;
	}

	override public function parentChanged(p:DisplayObjectContainer):void
	{
		super.parentChanged(p);

		if (p != null)
		{
			_parent = p; // так как наше AbstractView не есть ни IStyleClient, ни ISystemManager
		}
	}
}
}