package cocoa
{
import flash.events.MouseEvent;

import mx.core.IFlexDisplayObject;
import mx.core.IVisualElement;
import mx.core.mx_internal;
import mx.managers.IFocusManagerComponent;

import spark.components.DataGroup;
import spark.components.IItemRenderer;
import spark.events.RendererExistenceEvent;

use namespace mx_internal;

[Abstract]
public class SelectableDataGroup extends DataGroup
{
	protected var selectionChanged:Boolean = false;

	public function SelectableDataGroup()
	{
		super();

		addEventListener(RendererExistenceEvent.RENDERER_ADD, rendererAddHandler);
		addEventListener(RendererExistenceEvent.RENDERER_REMOVE, rendererRemoveHandler);
	}

	private var _iconFunction:Function;
	public function set iconFunction(value:Function):void
	{
		_iconFunction = value;
	}

	private var _selectOnDown:Boolean;
	public function set selectOnMouseDown(value:Boolean):void
	{
		_selectOnDown = value;
	}

	protected function get mouseEventTypeForItemSelect():String
	{
		return _selectOnDown ? MouseEvent.MOUSE_DOWN : MouseEvent.CLICK;
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

	private function rendererAddHandler(event:RendererExistenceEvent):void
	{
		event.renderer.addEventListener(mouseEventTypeForItemSelect, itemMouseSelectHandler);
		if (event.renderer is IFocusManagerComponent)
		{
			IFocusManagerComponent(event.renderer).focusEnabled = false;
		}
	}

	private function rendererRemoveHandler(event:RendererExistenceEvent):void
	{
		event.renderer.removeEventListener(mouseEventTypeForItemSelect, itemMouseSelectHandler);
	}

	private function itemMouseSelectHandler(event:MouseEvent):void
    {
		itemSelecting(event.currentTarget is IItemRenderer ? IItemRenderer(event.currentTarget).itemIndex : getElementIndex(IVisualElement(event.currentTarget)));
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

	public function itemToIcon(item:Object):IFlexDisplayObject
    {
		return _iconFunction(item);
	}
}
}