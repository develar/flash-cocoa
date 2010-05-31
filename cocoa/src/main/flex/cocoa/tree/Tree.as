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
import flash.utils.setInterval;

import mx.collections.ICollectionView;
import mx.collections.IViewCursor;
import mx.controls.Tree;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseContentHolder;
import mx.controls.treeClasses.TreeListData;
import mx.core.DragSource;
import mx.core.EdgeMetrics;
import mx.core.IFlexDisplayObject;
import mx.core.IInvalidating;
import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.events.DragEvent;
import mx.events.ListEvent;
import mx.managers.DragManager;
import mx.skins.halo.ListDropIndicator;

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

	//	override protected function drawItem(item:IListItemRenderer, selected:Boolean = false, highlighted:Boolean = false, caret:Boolean = false, transition:Boolean = false):void
	//	{
	//		if (!item)
	//        {
	//            return;
	//        }
	//        super.drawItem(item, selected, highlighted, caret, transition);
	//        if ("selected" in item)
	//        {
	//            var useSelectedItem:Boolean = selectedItem != null;
	//            var usePrevSelectedItem:Boolean = !useSelectedItem && _previousSelectedItems && _previousSelectedItems[0];
	//            var selectedElement:Object = useSelectedItem ? selectedItem : (usePrevSelectedItem ? _previousSelectedItems[0] : null);
	//            var selectedState:Boolean = selectedElement ? item.data == selectedElement : false;
	//            ItemRenderer(item).selected = selected || selectedState;
	//        }
	//	}

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

		var dragData:Array = dragSource.dataForFormat("treeItems") as Array;
		if (dragData != null && dragData.length != 0 && dragData[0])
		{
			DragManager.doDrag(this, dragSource, event, dragImage, -mouseX, 16 - mouseY, 0.5, dragMoveEnabled);
		}
	}

	override protected function dragEnterHandler(event:DragEvent):void
	{
		event.ctrlKey = false;
		super.dragEnterHandler(event);
	}

	override protected function dragOverHandler(event:DragEvent):void
	{
		if (event.isDefaultPrevented())
			return;

		lastDragEvent = event;

		var dragData:Object = event.dragSource.dataForFormat(_customItemType);

		if (enabled && iteratorValid && event.dragSource.hasFormat(_customItemType))
		{
			showDropFeedback(event);
			if (getParentItem(dragData[0]))
			{
				//DragManager.showFeedback(event.ctrlKey ? DragManager.COPY : DragManager.MOVE);
				DragManager.showFeedback(_dropData.parent ? DragManager.MOVE : DragManager.NONE);
			}
			return;
		}
		hideDropFeedback(event);
		DragManager.showFeedback(DragManager.NONE);
	}

	override protected function dragCompleteHandler(event:DragEvent):void
	{
		super.dragCompleteHandler(event);
		hideDropFeedback(event);
	}

	override protected function addDragData(ds:Object):void // actually a DragSource
	{
		var ir:IListItemRenderer = itemToItemRenderer(selectedItem);

		if (!ir || (ir && ir is IDropInListItemRenderer && TreeListData(IDropInListItemRenderer(ir).listData).depth == 1))
		{
			return;
		}

		ds.addData([selectedItem], "treeItems");
		if (_customItemType != "treeItems")
		{
			ds.addData([selectedItem], _customItemType);
		}
	}

	override public function showDropFeedback(event:DragEvent):void
	{
		/**
		 *   this part copied
		 *   from ListBase.as
		 */

		if (!dropIndicator)
		{
			var dropIndicatorClass:Class = getStyle("dropIndicatorSkin");
			if (!dropIndicatorClass)
				dropIndicatorClass = ListDropIndicator;
			dropIndicator = IFlexDisplayObject(new dropIndicatorClass());

			var vm:EdgeMetrics = viewMetrics;

			drawFocus(true);

			dropIndicator.x = 2;
			dropIndicator.setActualSize(listContent.width - 4, 4);
			dropIndicator.visible = true;
			listContent.addChild(DisplayObject(dropIndicator));

			if (collection)
			{
				if (dragScrollingInterval == 0)
					dragScrollingInterval = setInterval(dragScroll, 15);
			}
		}

		var rowCount:int = listItems.length;
		var partialRow:int = (rowInfo[rowCount - offscreenExtraRowsBottom - 1].y +
				rowInfo[rowCount - offscreenExtraRowsBottom - 1].height >
				listContent.heightExcludingOffsets - listContent.topOffset) ? 1 : 0;

		var rowNum:Number = calculateDropIndex(event);
		rowNum -= verticalScrollPosition;

		var rc:Number = listItems.length;
		if (rowNum >= rc)
		{
			if (partialRow)
				rowNum = rc - 1;
			else
				rowNum = rc;
		}

		if (rowNum < 0)
			rowNum = 0;

		dropIndicator.y = calculateDropIndicatorY(rc, rowNum + offscreenExtraRowsTop) - 2;

		/**
		 *   this part copied
		 *   from Tree.as
		 */

		// Adjust for indent
		vm = viewMetrics;
		var offset:int = 0;
		updateDropData(event);
		var indent:int = 0;
		var depth:int;
		if (_dropData.parent)
		{
			offset = getItemIndex(iterator.current);
			depth = getItemDepth(_dropData.parent, Math.abs(offset - getItemIndex(_dropData.parent)));
			indent = (depth + 1) * getStyle("indentation");
		}
		/*else
		 {
		 indent = getStyle("indentation");
		 }*/

		dropIndicator.visible = _dropData.parent != null;
		if (indent < 0)
			indent = 0;

		//position drop indicator
		/*dropIndicator.width = listContent.width - indent;
		 dropIndicator.x = indent + vm.left + 2;*/
		if (_dropData.emptyFolder)
		{
			dropIndicator.width = listContent.width - 2;
			dropIndicator.x = 1;
			if (Object(dropIndicator).hasOwnProperty("mode"))
			{
				Object(dropIndicator).mode = "drawRect";
			}
			dropIndicator.height = _dropData.rowHeight - 2;
			//dropIndicator.y += _dropData.rowHeight / 2;
		}
		else
		{
			dropIndicator.width = listContent.width - indent - 4;
			dropIndicator.x = indent + vm.left + 2;
			if (Object(dropIndicator).hasOwnProperty("mode"))
			{
				Object(dropIndicator).mode = "drawLine";
			}
			dropIndicator.height = 4;
		}
	}

	private function updateDropData(event:DragEvent):void
	{
		//		var rowCount:int = rowInfo.length;
		var rowNum:int = 0;
		var yy:int = rowInfo[rowNum].height;
		var pt:Point = globalToLocal(new Point(event.stageX, event.stageY));
		while (rowInfo[rowNum] && pt.y >= yy)
		{
			if (rowNum != rowInfo.length - 1)
			{
				rowNum++;
				yy += rowInfo[rowNum].height;
			}
			else
			{
				// now we're past all rows.  adding a pixel or two should be enough.
				// at this point yOffset doesn't really matter b/c we're past all elements
				// but might as well try to keep it somewhat correct
				yy += rowInfo[rowNum].height;
				rowNum++;
			}
		}

		var lastRowY:Number = rowNum < rowInfo.length ? rowInfo[rowNum].y : (rowInfo[rowNum - 1].y + rowInfo[rowNum - 1].height);
		var yOffset:Number = pt.y - lastRowY;
		var rowHeight:Number = rowNum < rowInfo.length ? rowInfo[rowNum].height : rowInfo[rowNum - 1].height;

		rowNum += verticalScrollPosition;

		var parent:Object;
		var index:int;
		var emptyFolder:Boolean = false;
		var numItems:int = collection ? collection.length : 0;

		var topItem:Object = (rowNum > _verticalScrollPosition && rowNum <= numItems) ?
				listItems[rowNum - _verticalScrollPosition - 1][0].data : null;
		var bottomItem:Object = (rowNum - verticalScrollPosition < rowInfo.length && rowNum < numItems) ?
				listItems[rowNum - _verticalScrollPosition][0].data : null;

		var topParent:Object = collection ? getParentItem(topItem) : null;
		var bottomParent:Object = collection ? getParentItem(bottomItem) : null;

		// check their relationship

		/**
		 *   this method copied
		 *   from Tree.as and 2 next lines was modified
		 */

		if (yOffset > rowHeight * .5)// && ac && ac.length == 0)
		{
			// we'll get here if we're dropping into an empty folder.
			// we have to be in the lower 50% of the row, otherwise
			// we're "between" rows.
			if (bottomItem)
			{
				parent = bottomItem;
				index = 0;
				emptyFolder = true;
			}
		}
		else if (topItem == null) // WTF? && !rowNum == rowCount
		{
			parent = collection ? getParentItem(bottomItem) : null;
			index = bottomItem ? getChildIndexInParent(parent, bottomItem) : 0;
			rowNum = 0;
		}
		else if (bottomItem && bottomParent == topItem)
		{
			// we're dropping in the first item of a folder, that's an easy one
			parent = topItem;
			index = 0;
		}
		else if (topItem && bottomItem && topParent == bottomParent)
		{
			parent = collection ? getParentItem(topItem) : null;
			index = iterator ? getChildIndexInParent(parent, bottomItem) : 0;
		}
		else
		{
			//we're dropping at the end of a folder.  Pay attention to the position.
			if (topItem && (yOffset < (rowHeight * .5)))
			{
				// ok, we're on the top half of the bottomItem.
				parent = topParent;
				index = getChildIndexInParent(parent, topItem) + 1; // insert after
			}
			else if (!bottomItem)
			{
				parent = null;
				if ((rowNum - verticalScrollPosition) == 0)
					index = 0;
				else if (collection)
					index = collection.length;
				else index = 0;
			}
			else
			{
				parent = bottomParent;
				index = getChildIndexInParent(parent, bottomItem);
			}
		}
		_dropData = { parent: parent, index: index, localX: event.localX, localY: event.localY,
			emptyFolder: emptyFolder, rowHeight: rowHeight, rowIndex: rowNum };
	}

	private function getChildIndexInParent(parent:Object, child:Object):int
	{
		var index:int = 0;
		if (!parent)
		{
			var cursor:IViewCursor = ICollectionView(iterator.view).createCursor();
			while (!cursor.afterLast)
			{
				if (child === cursor.current)
					break;
				index++;
				cursor.moveNext();
			}
		}
		else
		{
			if (parent != null &&
					_dataDescriptor.isBranch(parent, iterator.view) &&
					_dataDescriptor.hasChildren(parent, iterator.view))
			{
				var children:ICollectionView = getChildren(parent, iterator.view);
				if (children.contains(child))
				{
					cursor = children.createCursor();
					while (!cursor.afterLast)
					{
						if (child === cursor.current)
							break;
						cursor.moveNext();
						index++;
					}

				}
				else
				{
					//throw new Error("Parent item does not contain specified child: " + itemToUID(child));
				}
			}
		}
		return index;
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


	protected override function mouseDownHandler(event:MouseEvent):void
	{
		var r:IListItemRenderer = mouseEventToRenderer(event);
		//click on disclosure icon shouldn't select the item
		if (r == null || !dataDescriptor.isBranch(r.data) || !TreeItemRenderer(r).checkDisclosure(event, false))
		{
			super.mouseDownHandler(event);
		}
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
			drawItemBorder(item.width, rowInfo[rowData.rowIndex].height, item, 2);
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
		border.bitmapIndex = index;

		var oldFrameX:Number = border.frameInsets.left;
		border.frameInsets.left += TreeListData(IDropInListItemRenderer(itemRenderer).listData).indent;

		var g:Graphics = Sprite(itemRenderer).graphics;
		g.clear();
		_border.draw(null, g, width, height);

		border.frameInsets.left = oldFrameX;
	}

	override protected function drawRowBackgrounds():void
	{

	}

	override protected function drawCaretIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
	{

	}

	protected override function mouseClickHandler(event:MouseEvent):void
	{
		if (event.target is TreeItemRenderer)
		{
			if (TreeItemRenderer(event.target).checkDisclosure(event))
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
}
}