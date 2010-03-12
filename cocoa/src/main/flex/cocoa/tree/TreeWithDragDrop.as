package cocoa.tree
{
import cocoa.EditableItemRenderer;

import flash.events.MouseEvent;

import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.treeClasses.TreeListData;
import mx.core.DragSource;
import mx.core.SpriteAsset;
import mx.core.mx_internal;
import mx.events.DragEvent;
import mx.managers.DragManager;

import spark.components.supportClasses.ItemRenderer;

use namespace mx_internal;

public class TreeWithDragDrop extends Tree
{
	public var treeLastDropIndex:int;

	override public function set selectedItem(data:Object):void
	{
		super.selectedItem = data;
		_previousSelectedItems = [];
		_previousSelectedItems[0] = data;
	}


	[Bindable("collectionChange")]
	[Inspectable(category="Data", defaultValue="null")]
	override public function set dataProvider(value:Object):void
	{
		if (dataProvider != value)
		{
			super.dataProvider = value;
			copyModeLocked = false;
		}
	}

	private var _allowDragBranches:Boolean = true;
	public function get allowDragBranches():Boolean
	{
		return _allowDragBranches;
	}

	public function set allowDragBranches(value:Boolean):void
	{
		_allowDragBranches = value;
	}

	public var copyModeLocked:Boolean = false;// actually doesn't lock anything - it was introduced to explicitly switch DragManager to the COPY mode in dragOverHandler.

	override protected function drawItem(item:IListItemRenderer, selected:Boolean = false, highlighted:Boolean = false, caret:Boolean = false, transition:Boolean = false):void
	{
		if (!item)
		{
			return;
		}
		super.drawItem(item, selected, highlighted, caret, transition);

		if ("selected" in item)
		{
			var useSelectedItem:Boolean = selectedItem != null;
			var usePrevSelectedItem:Boolean = !useSelectedItem && _previousSelectedItems && _previousSelectedItems[0];
			var selectedElement:Object = useSelectedItem ? selectedItem : (usePrevSelectedItem ? _previousSelectedItems[0] : null);
			var selectedState:Boolean = selectedElement ? item.data == selectedElement : false;
			//ItemRenderer(item).selected = selected || selectedState;
			ItemRenderer(item).selected = !TreeListData(IDropInListItemRenderer(item).listData).hasChildren && (selected || selectedState);
		}
	}

	override protected function mouseDownHandler(event:MouseEvent):void
	{
		if (!_allowDragBranches)
		{
			var currentRenderer:IListItemRenderer = mouseEventToItemRenderer(event);
			if (currentRenderer && IDropInListItemRenderer(currentRenderer).listData is TreeListData
					&& TreeListData(IDropInListItemRenderer(currentRenderer).listData).hasChildren)
				return;
		}
		super.mouseDownHandler(event);
	}

	override protected function dragStartHandler(event:DragEvent):void
	{
		if (event.isDefaultPrevented())
			return;

		var item:IListItemRenderer = selectedItem ? itemToItemRenderer(selectedItem) : null;
		if (item && item is EditableItemRenderer && EditableItemRenderer(item).editMode)
		{
			return;
		}

		var dragSource:DragSource = new DragSource();

		addDragData(dragSource);

		DragManager.doDrag(this, dragSource, event, new SpriteAsset(),
				0, 0, 0.5, dragMoveEnabled);
	}

	override protected function dragOverHandler(event:DragEvent):void
	{
		if (event.isDefaultPrevented())
			return;

		lastDragEvent = event;

		if (enabled && iteratorValid && event.dragSource.hasFormat(customItemType))
		{
			DragManager.showFeedback(copyModeLocked ? DragManager.COPY : DragManager.MOVE);
			showDropFeedback(event);
			return;
		}
		hideDropFeedback(event);
		DragManager.showFeedback(DragManager.NONE);
	}

	override protected function addDragData(ds:Object):void // actually a DragSource
	{
		ds.addData([selectedItem], "treeItems");
		if (customItemType != "treeItems")
			ds.addData([selectedItem], customItemType);
	}

	public function getDropItem():IListItemRenderer
	{
		var rowNum:int = Math.floor(_dropData.localY / rowHeight);
		var ind:int = indicesToIndex(rowNum + verticalScrollPosition, 0);
		return indexToItemRenderer(ind);
	}
}
}