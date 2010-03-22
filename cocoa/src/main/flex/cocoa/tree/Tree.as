package cocoa.tree
{
import cocoa.IEditable;

import cocoa.Viewable;

import flash.display.DisplayObject;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.setInterval;

import mx.collections.ICollectionView;
import mx.collections.IViewCursor;
import mx.controls.Tree;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.treeClasses.TreeListData;
import mx.core.DragSource;
import mx.core.EdgeMetrics;
import mx.core.IFlexDisplayObject;
import mx.core.IUIComponent;
import mx.core.mx_internal;
import mx.events.DragEvent;
import mx.managers.DragManager;
import mx.skins.halo.ListDropIndicator;

use namespace mx_internal;

[Exclude(name="shadowDirection", kind="style")]
[Exclude(name="backgroundColor", kind="style")]
[Exclude(name="shadowDistance", kind="style")]
[Exclude(name="borderThickness", kind="style")]

[Style(name="pageIcon", type="Class", format="EmbeddedFile")]
public class Tree extends mx.controls.Tree implements IEditable, Viewable
{
	public function Tree()
	{
		super();

		dataDescriptor = new TreeDataDescriptor();
	}
	
	private var _editMode:Boolean = false;
	public function get editMode():Boolean
	{
		return _editMode;
	}

	public function set editMode(value:Boolean):void
	{
		_editMode = value;
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
        var rowCount:int = rowInfo.length;
        var rowNum:int = 0;
        var yy:int = rowInfo[rowNum].height;
        var pt:Point = globalToLocal(new Point(event.stageX, event.stageY));
		while (rowInfo[rowNum] && pt.y >= yy)
		{
		    if (rowNum != rowInfo.length-1)
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

        var lastRowY:Number = rowNum < rowInfo.length ? rowInfo[rowNum].y : (rowInfo[rowNum-1].y + rowInfo[rowNum-1].height);
        var yOffset:Number = pt.y - lastRowY;
        var rowHeight:Number = rowNum < rowInfo.length ? rowInfo[rowNum].height : rowInfo[rowNum-1].height;

        rowNum += verticalScrollPosition;

        var parent:Object;
        var index:int;
        var emptyFolder:Boolean = false;
        var numItems:int = collection ? collection.length : 0;

        var topItem:Object = (rowNum > _verticalScrollPosition && rowNum <= numItems) ?
        					 listItems[rowNum - _verticalScrollPosition - 1][0].data : null;
        var bottomItem:Object = (rowNum - verticalScrollPosition < rowInfo.length && rowNum < numItems) ?
        						listItems[rowNum - _verticalScrollPosition][0].data  : null;

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
        else if (!topItem && !rowNum == rowCount)
        {
            parent = collection ? getParentItem(bottomItem) : null;
            index =  bottomItem ? getChildIndexInParent(parent, bottomItem) : 0;
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

	override protected function keyDownHandler(event:KeyboardEvent):void
    {
		if (_editMode)
		{
			return;
		}
		super.keyDownHandler(event);
	}

	public function mouseEventToRenderer(event:MouseEvent):IListItemRenderer
    {
        return mouseEventToItemRenderer(event);
    }
}
}