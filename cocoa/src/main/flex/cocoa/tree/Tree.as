package cocoa.tree
{
import cocoa.AbstractView;
import cocoa.Border;
import cocoa.View;
import cocoa.border.AbstractMultipleBitmapBorder;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.errors.IllegalOperationError;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.setInterval;

import mx.controls.Tree;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseContentHolder;
import mx.controls.treeClasses.TreeListData;
import mx.core.DragSource;
import mx.core.EdgeMetrics;
import mx.core.IFactory;
import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.events.DragEvent;
import mx.events.ListEvent;
import mx.managers.DragManager;
import mx.styles.StyleProtoChain;

use namespace mx_internal;

[Exclude(name="shadowDirection", kind="style")]
[Exclude(name="backgroundColor", kind="style")]
[Exclude(name="shadowDistance", kind="style")]
[Exclude(name="borderThickness", kind="style")]

[Style(name="pageIcon", type="Class", format="EmbeddedFile")]
public class Tree extends mx.controls.Tree implements View
{
	private var lafDefaults:Object;

	public function Tree()
	{
		super();

		dataDescriptor = new TreeDataDescriptor();
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

	override protected function get dragImage():IUIComponent
	{
		var renderer:IListItemRenderer = createItemRenderer(lastMouseDownItem.data);
		renderer.data = lastMouseDownItem.data;
		if (renderer is IDropInListItemRenderer)
		{
			IDropInListItemRenderer(renderer).listData = IDropInListItemRenderer(lastMouseDownItem).listData;
		}
		return renderer;
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
		lastDragEvent = event;
	}

	override protected function dragOverHandler(event:DragEvent):void
	{
		//should be handled by external manager
		lastDragEvent = event;
		if (collection)
		{
			if (dragScrollingInterval == 0)
			{
				dragScrollingInterval = setInterval(dragScroll, 15);
			}
		}
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
	 * since the mouse down on a disclosure icon is prevented and clicked item not selected
	 * last clicked itemRenderer stored here for handle dragStart
	 */
	private var _lastMouseDownItemRenderer:IListItemRenderer;

	public function get lastMouseDownItem():IListItemRenderer
	{
		return _lastMouseDownItemRenderer;
	}

	override protected function mouseDownHandler(event:MouseEvent):void
	{
		var renderer:IListItemRenderer = mouseEventToRenderer(event);
		// click on a disclosure icon shouldn't select the item
		if (renderer == null || !dataDescriptor.hasChildren(renderer.data) || !TreeItemRenderer(renderer).checkDisclosure(event, false))
		{
			super.mouseDownHandler(event);
		}

		_lastMouseDownItemRenderer = renderer;
	}

	override protected function mouseUpHandler(event:MouseEvent):void
	{
		super.mouseUpHandler(event);
	}

	override protected function createChildren():void
	{
		var laf:LookAndFeel = LookAndFeelProvider(parent).laf;
		lafDefaults = laf.getObject("Tree.defaults");
		_border = laf.getBorder("Tree.border");
		rowHeight = _border.layoutHeight;

		listContent = new StylessListBaseContentHolder(this);
		addChild(listContent);

		super.createChildren();
	}

	public function isRendererHighlighted(item:IListItemRenderer):Boolean
	{
		return highlightItemRenderer == item;
	}

	override protected function drawItem(itemRenderer:IListItemRenderer, selected:Boolean = false, highlighted:Boolean = false, caret:Boolean = false, transition:Boolean = false):void
	{
		var contentHolder:ListBaseContentHolder = DisplayObject(itemRenderer).parent as ListBaseContentHolder;
		if (contentHolder == null)
		{
			return;
		}

		var rowInfo:Array = contentHolder.rowInfo;
		var rowData:TreeListData = rowMap[itemRenderer.name];
		// this can happen due to race conditions when using data effects
		if (rowData == null)
		{
			return;
		}

		const isCustomRenderer:Boolean = !(itemRenderer is TreeItemRenderer);

		if (highlighted && (highlightItemRenderer == null || highlightUID != rowData.uid))
		{
			lastHighlightItemRenderer = highlightItemRenderer = itemRenderer;
			highlightUID = rowData.uid;
		}
		else
		{
			if (highlightItemRenderer != null && highlightUID == rowData.uid)
			{
				highlightItemRenderer = null;
				highlightUID = null;
			}
		}

		if (isCustomRenderer)
		{
			if (selected)
			{
				drawItemBorder(itemRenderer.width, rowInfo[rowData.rowIndex].height, itemRenderer, 1);
			}
			else
			{
				if (!highlighted)
				{
					Sprite(itemRenderer).graphics.clear();
				}
				else
				{
					drawItemBorder(itemRenderer.width, rowInfo[rowData.rowIndex].height, itemRenderer, 0);
				}
			}
		}
		else
		{
			TreeItemRenderer(itemRenderer).invalidateDisplayList();
		}

		if (caret && showCaret)
		{
			caretItemRenderer = itemRenderer;
			caretUID = rowData.uid;
		}
		else
		{
			if (caretItemRenderer != null && caretUID == rowData.uid)
			{
				clearCaretIndicator(caretIndicator, itemRenderer);
				caretItemRenderer = null;
				caretUID = "";
			}
		}
	}

	public function drawItemBorder(width:Number, height:Number, itemRenderer:IListItemRenderer, index:int = -1):void
	{
		var g:Graphics = Sprite(itemRenderer).graphics;
		if (index == -1)
		{
			if (isItemSelected(itemRenderer.data))
			{
				index = 1;
			}
			else
			{
				if (highlightItemRenderer == itemRenderer)
				{
					index = 0;
				}
				else
				{
					return;
				}
			}
		}
		else
		{
			// в Cocoa нет hover state и border отрисовывается на всю ширину дерева, не на ширину элемента (listData.indent) — нам пока не с руки делать это через конфигурацию
			g.clear();
		}

		if (_border is AbstractMultipleBitmapBorder)
		{
			AbstractMultipleBitmapBorder(_border).stateIndex = index;
			var oldFrameX:Number = _border.frameInsets.left;
			_border.frameInsets.left += TreeListData(IDropInListItemRenderer(itemRenderer).listData).indent;
			_border.draw(null, g, width, height);
			_border.frameInsets.left = oldFrameX;
		}
		else
		{
			if (index != 0)
			{
				_border.draw(null, g, width, height);
			}
		}
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

	// disable unwanted legacy

	override public function setStyle(styleProp:String, newValue:*):void
	{
		if (nonInheritingStyles == StyleProtoChain.STYLE_UNINITIALIZED)
		{
			nonInheritingStyles = {};
		}

		nonInheritingStyles[styleProp] = newValue;
	}

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

	override public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void
	{

	}

	override mx_internal function initThemeColor():Boolean
	{
		return true;
	}

	include "../../../legacyConstraints.as";

	override public function getStyle(styleProp:String):*
	{
		if (styleProp in nonInheritingStyles)
		{
			return nonInheritingStyles[styleProp];
		}
		else if (styleProp in lafDefaults)
		{
			return lafDefaults[styleProp];
		}
		else if (styleProp == "verticalAlign")
		{
			return "top";
		}
		else
		{
//			throw new Error("unknown " + styleProp);
//			trace(styleProp);
			return undefined;
		}
	}

	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		if ("borderColor" in lafDefaults)
		{
			var g:Graphics = graphics;
			g.clear();
			g.lineStyle(1, lafDefaults.borderColor);
			g.beginFill(0xffffff);
			g.drawRect(0, 0, unscaledWidth, unscaledHeight);
			g.endFill();
		}

		super.updateDisplayList(unscaledWidth, unscaledHeight);
	}

	override protected function createBorder():void
	{

	}

	private static const BORDER_METRICS:EdgeMetrics = new EdgeMetrics(1, 1, 1, 1);

	override public function get borderMetrics():EdgeMetrics
	{
		return "borderColor" in lafDefaults ? BORDER_METRICS : EdgeMetrics.EMPTY;
	}

	override protected function makeListData(item:Object, uid:String, rowNum:int):BaseListData
	{
		var treeListData:TreeListData = new TreeListData(itemToLabel(item), uid, this, rowNum);

		treeListData.open = isItemOpen(item);
		treeListData.hasChildren = _dataDescriptor.hasChildren(item, iterator.view);
		treeListData.depth = getItemDepth(item, treeListData.rowIndex);
		treeListData.indent = (treeListData.depth - 1) * getStyle("indentation");
		treeListData.item = item;
		//		treeListData.icon = itemToIcon(item);

		return treeListData;
	}

	override public function itemToIcon(item:Object):Class
	{
		// пока что никому не надо, а потом мы напишем реализацию отдачи иконки
		return null;
	}
}
}

import cocoa.AbstractView;

import mx.controls.listClasses.ListBase;
import mx.controls.listClasses.ListBaseContentHolder;
import mx.core.mx_internal;

use namespace mx_internal;

class StylessListBaseContentHolder extends ListBaseContentHolder
{
	public function StylessListBaseContentHolder(parentList:ListBase)
	{
		super(parentList);
	}

	override public function setStyle(styleProp:String, newValue:*):void
	{
	}

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

	override public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void
	{

	}

	override mx_internal function initThemeColor():Boolean
	{
		return true;
	}
}