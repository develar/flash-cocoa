package cocoa.tree
{
import cocoa.Border;
import cocoa.View;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Scale3EdgeHBitmapBorder;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.errors.IllegalOperationError;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.controls.Tree;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseContentHolder;
import mx.controls.treeClasses.TreeListData;
import mx.core.DragSource;
import mx.core.IFactory;
import mx.core.IFlexDisplayObject;
import mx.core.IInvalidating;
import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.events.DragEvent;
import mx.events.ListEvent;
import mx.managers.DragManager;

use namespace mx_internal;

[Exclude(name="shadowDirection", kind="style")]
[Exclude(name="backgroundColor", kind="style")]
[Exclude(name="shadowDistance", kind="style")]
[Exclude(name="borderThickness", kind="style")]

[Style(name="pageIcon", type="Class", format="EmbeddedFile")]
public class Tree extends mx.controls.Tree implements View
{

	public function Tree()
	{
		super();

		dataDescriptor = new TreeDataDescriptor();

		setStyle("paddingTop", 0);
		setStyle("paddingBottom", 0);
		setStyle("paddingLeft", 3);
		setStyle("paddingRight", 3);
	}

	private var _border:Border;

	public function get $border():Border
	{
		return _border;
	}

	[Bindable("collectionChange")]
	[Inspectable(category="Data", defaultValue="null")]
	override public function set dataProvider(value:Object):void
	{
		if (dataProvider != value)
		{
			super.dataProvider = value;
		}
	}

	private var _customItemType:String = "treeItems";
	public function get customItemType():String
	{
		return _customItemType;
	}

	public function set customItemType(value:String):void
	{
		_customItemType = value;
	}

	protected var _previousSelectedItems:Array;
	public function get previousSelectedItems():Array
	{
		return _previousSelectedItems;
	}

	public function set previousSelectedItems(value:Array):void
	{
		_previousSelectedItems = value;
	}

	override protected function get dragImage():IUIComponent
	{
		return null;
		//        var image:Image = new Image();
		//        image.source = getStyle("pageIcon");
		//        return image;
	}

	override protected function dragStartHandler(event:DragEvent):void
	{
		if (event.isDefaultPrevented())
		{
			return;
		}

		var dragSource:DragSource = new DragSource();
		addDragData(dragSource);

		var dragData:Array = dragSource.dataForFormat(_customItemType) as Array;
		if (dragData != null && dragData.length != 0 && dragData[0])
		{
			DragManager.doDrag(this, dragSource, event, dragImage, -mouseX, 16 - mouseY, 0.5, dragMoveEnabled);
		}
	}

	override protected function dragEnterHandler(event:DragEvent):void
	{
		//should be handled by external manager
	}

	override protected function dragOverHandler(event:DragEvent):void
	{
		//should be handled by external manager
		lastDragEvent = event;
	}


	protected override function dragDropHandler(event:DragEvent):void
	{
		//should be handled by external manager
		hideDropFeedback(event);
		lastDragEvent = null;
	}

	override protected function dragCompleteHandler(event:DragEvent):void
	{
		isPressed = false;
		clearSelected(false);
		resetDragScrolling();
	}

	override protected function addDragData(ds:Object):void // actually a DragSource
	{
		ds.addData([_lastMouseDownItemRenderer.data], _customItemType);
	}

	/*override protected function keyDownHandler(event:KeyboardEvent):void
	 {
	 super.keyDownHandler(event);
	 }*/

	public function mouseEventToRenderer(event:MouseEvent):IListItemRenderer
	{
		return mouseEventToItemRenderer(event);
	}

	public function addDisplayObject(displayObject:DisplayObject, index:int = -1):void
	{
		throw new IllegalOperationError("unsupported");
	}

	public function removeDisplayObject(displayObject:DisplayObject):void
	{
		throw new IllegalOperationError("unsupported");
	}

	/**
	 * Implements custom item_edit_beginig  instead of flex itemClick behaviour
	 * Make sure that the item to be edited is among visible renderers
	 */
	public function showItemEditor(item:Object):void
	{
		var renderer:IListItemRenderer = itemToItemRenderer(item);
		assert(renderer != null);
		editable = true;
		var listEvent:ListEvent = new ListEvent(ListEvent.ITEM_EDIT_BEGINNING, false, true);
		var pos:Point = itemRendererToIndices(renderer);
		listEvent.rowIndex = pos.y;
		listEvent.columnIndex = 0;
		listEvent.itemRenderer = renderer;
		dispatchEvent(listEvent);
	}

	override protected function endEdit(reason:String):Boolean
	{
		//prevent futher editing if user clicks on another itemRenderer
		editable = false;
		return super.endEdit(reason);
	}

	/**
	 * since the mouse down on a disclosure icon is prevented and clicked item doesn't selected
	 * last clicked itemRenderer stored here for handle dragStart
	 */
	private var _lastMouseDownItemRenderer:IListItemRenderer;

	public function get lastMouseDownItem():IListItemRenderer
	{
		return _lastMouseDownItemRenderer;
	}

	protected override function mouseDownHandler(event:MouseEvent):void
	{
		var r:IListItemRenderer = mouseEventToRenderer(event);
		//click on disclosure icon shouldn't select the item
		if (r == null || !dataDescriptor.isBranch(r.data) || !TreeItemRenderer(r).checkDisclosure(event, false))
		{
			super.mouseDownHandler(event);
		}
		_lastMouseDownItemRenderer = r;
	}

	protected override function createChildren():void
	{
		_border = LookAndFeelProvider(parent).laf.getBorder("Tree.border");
		rowHeight = _border.layoutHeight;

		super.createChildren();
	}

	override protected function drawItem(item:IListItemRenderer, selected:Boolean = false, highlighted:Boolean = false, caret:Boolean = false, transition:Boolean = false):void
	{
		if (!item)
		{
			return;
		}

		//		if (!(item is TreeItemRenderer))
		//		{
		//			super.drawItem(item, selected, highlighted, caret, transition);
		//			return;
		//		}

		var contentHolder:ListBaseContentHolder = DisplayObject(item).parent as ListBaseContentHolder;
		if (!contentHolder)
		{
			return;
		}

		var rowInfo:Array = contentHolder.rowInfo;
		var rowData:BaseListData = rowMap[item.name];
		// this can happen due to race conditions when using data effects
		if (!rowData)
		{
			return;
		}

		if (highlighted && (highlightItemRenderer == null || highlightUID != rowData.uid))
		{
			drawItemBorder(item.width, rowInfo[rowData.rowIndex].height, item, 0);

			lastHighlightItemRenderer = highlightItemRenderer = item;
			highlightUID = rowData.uid;
		}
		else if (highlightItemRenderer && (rowData && highlightUID == rowData.uid))
		{
			clearHighlightIndicator(highlightIndicator, item);
			highlightItemRenderer = null;
			highlightUID = null;
		}

		if (selected)
		{
			drawItemBorder(item.width, rowInfo[rowData.rowIndex].height, item, 1);
		}
		else if (!highlighted)
		{
			Sprite(item).graphics.clear();
		}

		if (caret) // && (!caretItemRenderer || caretUID != rowData.uid))
		{
			// Only draw the caret if there has been keyboard navigation.
			if (showCaret)
			{
				//drawCaretIndicator(o, item.x, rowInfo[rowData.rowIndex].y, item.width, rowInfo[rowData.rowIndex].height, getStyle("selectionColor"), item);

				var oldCaretItemRenderer:IListItemRenderer = caretItemRenderer;
				caretItemRenderer = item;
				caretUID = rowData.uid;
				if (oldCaretItemRenderer is IFlexDisplayObject && oldCaretItemRenderer is IInvalidating)
				{
					IInvalidating(oldCaretItemRenderer).invalidateDisplayList();
					IInvalidating(oldCaretItemRenderer).validateNow();
				}
			}
		}
		else if (caretItemRenderer != null && caretUID == rowData.uid)
		{
			clearCaretIndicator(caretIndicator, item);
			caretItemRenderer = null;
			caretUID = "";
		}

		if (item is IFlexDisplayObject && item is IInvalidating)
		{
			IInvalidating(item).invalidateDisplayList();
			IInvalidating(item).validateNow();
		}
	}

	private function drawItemBorder(width:Number, height:Number, itemRenderer:IListItemRenderer, index:int):void
	{
		var border:Scale3EdgeHBitmapBorder = Scale3EdgeHBitmapBorder(_border);
		border.stateIndex = index;

		var oldFrameX:Number = border.frameInsets.left;
		border.frameInsets.left += TreeListData(IDropInListItemRenderer(itemRenderer).listData).indent;

		var g:Graphics = Sprite(itemRenderer).graphics;
		g.clear();
		_border.draw(null, g, width, height);

		border.frameInsets.left = oldFrameX;
	}

	override protected function drawCaretIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
	{

	}

	override protected function mouseClickHandler(event:MouseEvent):void
	{
		var item:TreeItemRenderer = mouseEventToItemRenderer(event) as TreeItemRenderer;
		if (item != null)
		{
			if (item.checkDisclosure(event))
			{
				return;
			}
		}

		super.mouseClickHandler(event);
	}

	override protected function layoutEditor(x:int, y:int, w:int, h:int):void
	{
		var data:TreeListData = rowMap[editedItemRenderer.name];
		var item:IListItemRenderer = listItems[data.rowIndex][0];
		var indent:int = data.indent;
		itemEditorInstance.move(indent + _border.contentInsets.left, y);
		itemEditorInstance.setActualSize(item.width - _border.contentInsets.left - indent + item.x, h);
	}

	override protected function moveIndicatorsVertically(uid:String, moveBlockDistance:Number):void
	{
		if (highlightIndicator != null)
		{
			super.moveIndicatorsVertically(uid, moveBlockDistance);
		}
	}

	override protected function moveIndicatorsHorizontally(uid:String, moveBlockDistance:Number):void
	{
		if (highlightIndicator != null)
		{
			super.moveIndicatorsHorizontally(uid, moveBlockDistance);
		}
	}

	public var itemRendererFunction:Function;

	override public function getItemRendererFactory(data:Object):IFactory
	{
		return itemRendererFunction == null ? super.getItemRendererFactory(data) : itemRendererFunction(data);
	}
}
}