package cocoa
{
import cocoa.layout.LayoutMetrics;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.text.engine.TextLine;

import mx.core.IFlexDisplayObject;
import mx.core.IVisualElement;
import mx.core.mx_internal;

import spark.components.DataGroup;
import spark.components.IItemRenderer;

use namespace mx_internal;

[Abstract]
public class SelectableDataGroup extends DataGroup
{
	private static const SELECT_ON_DOWN:uint = 1 << 0;
	private static const HIGHLIGHTABLE:uint = 1 << 1;
	private var flags:uint = 0;

	protected var selectionChanged:Boolean = false;

	private var highlightedRenderer:HighlightableItemRenderer;

	public function SelectableDataGroup()
	{
		super();

		mouseEnabled = false;
		addEventListener(mouseEventTypeForItemSelect, itemMouseSelectHandler);
	}

	private var _iconFunction:Function;
	public function set iconFunction(value:Function):void
	{
		_iconFunction = value;
	}

	public function set selectOnMouseDown(value:Boolean):void
	{
		value ? flags ^= SELECT_ON_DOWN : flags |= SELECT_ON_DOWN;
	}

	protected function get mouseEventTypeForItemSelect():String
	{
		return (flags & SELECT_ON_DOWN) == 0 ? MouseEvent.CLICK : MouseEvent.MOUSE_DOWN;
	}

	override protected function commitProperties():void
	{
		super.commitProperties();

		if (selectionChanged)
		{
			selectionChanged = false;

			commitSelection();
		}
	}

	[Abstract]
	protected function commitSelection():void
	{

	}

	private function itemMouseSelectHandler(event:MouseEvent):void
    {
		if (event.target != this)
		{
			var target:DisplayObject = DisplayObject(event.target);
			if (target is TextLine)
			{
				target = target.parent;
			}
			itemSelecting(target is IItemRenderer ? IItemRenderer(target).itemIndex : getElementIndex(IVisualElement(target)));
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

		if (renderer is IconedItemRenderer)
		{
			IconedItemRenderer(renderer).icon = itemToIcon(data);
		}
	}

	private function mouseOutOrOverHandler(event:MouseEvent):void
	{
		if (event.target != this)
		{
			if (event.type == MouseEvent.MOUSE_OVER)
			{
				if (highlightedRenderer != null)
				{
					highlightedRenderer.highlighted = false;
				}
				highlightedRenderer = HighlightableItemRenderer(event.target);
				highlightedRenderer.highlighted = true;
			}
			else
			{
				highlightedRenderer.highlighted = false;
				highlightedRenderer = null;
			}

			event.updateAfterEvent();
		}
		else if (highlightedRenderer != null)
		{
			highlightedRenderer.highlighted = false;
			highlightedRenderer = null;
			event.updateAfterEvent();
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

	mx_internal override function childAdded(child:DisplayObject):void
	{
		super.childAdded(child);

		if (child is HighlightableItemRenderer && (flags & HIGHLIGHTABLE) == 0)
		{
			flags |= HIGHLIGHTABLE;

			addEventListener(MouseEvent.MOUSE_OUT, mouseOutOrOverHandler);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOutOrOverHandler);
		}
	}
}
}