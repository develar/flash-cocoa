package cocoa.tree
{
import cocoa.AbstractView;
import cocoa.LabelHelper;
import cocoa.border.BitmapBorderStateIndex;
import cocoa.border.MultipleBorder;
import cocoa.plaf.TextFormatID;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.events.MouseEvent;

import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.treeClasses.TreeListData;
import mx.core.mx_internal;
import mx.events.TreeEvent;

use namespace mx_internal;

public class TreeItemRenderer extends AbstractView implements IListItemRenderer, IDropInListItemRenderer, MouseEventPreventer
{
	protected var icon:DisplayObject;

	protected var labelHelper:LabelHelper;

	private var listDataChanged:Boolean;

	public function TreeItemRenderer()
	{
		mouseChildren = false;
	}

	protected var _listData:TreeListData;
	public function get listData():BaseListData
	{
		return _listData;
	}

	public function set listData(value:BaseListData):void
	{
		if (value == _listData)
		{
			return;
		}

		_listData = TreeListData(value);
		listDataChanged = true;
		if (_listData == null)
		{
			return;
		}
		invalidateProperties();
		invalidateDisplayList();
	}

	override protected function createChildren():void
	{
		super.createChildren();

		if (icon == null)
		{
			//			var iconClass:Class = Tree(owner).getStyle("pageIcon");
			//			icon = new iconClass();
			//			icon.y = 2;
			//			addDisplayObject(icon);
		}

		labelHelper = new LabelHelper(this, LookAndFeelProvider(owner.parent).laf.getTextFormat(TextFormatID.SMALL_SYSTEM));
	}

	override protected function measure():void
	{
		super.measure();

		labelHelper.validate();

		// icon size 16, horizontal gap 0
		measuredWidth = _listData == null ? 32 : _listData.indent + 32 + labelHelper.textWidth;
		measuredHeight = 20;
	}

	protected function getLabel():String
	{
		return _listData.label;
	}

	override protected function commitProperties():void
	{
		super.commitProperties();

		if (listDataChanged)
		{
			listDataChanged = false;

			labelHelper.text = getLabel();
		}
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		if (w == 0 || h == 0)
		{
			return;
		}

		if (icon != null)
		{
			icon.x = _listData.indent + 16;
		}

		var g:Graphics = graphics;
		g.clear();

		Tree(owner).drawItemBorder(w, h, this);
		
		var selected:Boolean = Tree(owner).isItemSelected(data);
		var laf:LookAndFeel = LookAndFeelProvider(owner.parent).laf;
		if (_listData.hasChildren)
		{
			drawDisclosureIcon(laf, selected);
		}

		// @todo optimize
		if (isNaN(maxDisclosureIconWidth))
		{
			maxDisclosureIconWidth = Math.max(laf.getBorder("Tree.disclosureIcon.close", false).layoutWidth, laf.getBorder("Tree.disclosureIcon.open", false).layoutWidth);
		}

		labelHelper.textFormat = laf.getTextFormat(selected ? TextFormatID.SMALL_SYSTEM_HIGHLIGHTED : TextFormatID.SMALL_SYSTEM);
		labelHelper.validate();
		labelHelper.move(_listData.indent + maxDisclosureIconWidth + Tree(owner).$border.contentInsets.left, h - Tree(owner).$border.contentInsets.bottom);
	}

	protected function drawDisclosureIcon(laf:LookAndFeel, selected:Boolean):void
	{
		var g:Graphics = graphics;
		var disclosureBorder:MultipleBorder = MultipleBorder(laf.getBorder("Tree.disclosureIcon." + (_listData.open ? "close" : "open"), false));
		if (selected && disclosureBorder.hasState(BitmapBorderStateIndex.ON))
		{
			disclosureBorder.stateIndex = BitmapBorderStateIndex.ON;
		}
		else
		{
			disclosureBorder.stateIndex = BitmapBorderStateIndex.OFF;
		}

		var oldFrameX:Number = disclosureBorder.frameInsets.left;
		disclosureBorder.frameInsets.left += _listData.indent;
		disclosureBorder.draw(null, g, NaN, NaN);
		disclosureBorder.frameInsets.left = oldFrameX;
	}

	private var maxDisclosureIconWidth:Number;

	private var _data:Object;
	public function get data():Object
	{
		return _data;
	}

	public function set data(value:Object):void
	{
		if (value != data)
		{
			_data = value;
		}
	}

	private function isDisclosureIconClicked(event:MouseEvent):Boolean
	{
		var laf:LookAndFeel = LookAndFeelProvider(owner.parent).laf;
		var disclosureBorder:MultipleBorder = MultipleBorder(laf.getBorder("Tree.disclosureIcon." + (_listData.open ? "open" : "close"), false));
		// 3 чтобы при щелчке не надо было быть снайпером
		var localX:Number = event.localX  - _listData.indent;
		return event.localY >= (disclosureBorder.frameInsets.top - 3) && event.localY <= (disclosureBorder.layoutHeight + 3) &&
			   localX >= (disclosureBorder.frameInsets.left - 3) && localX <= (disclosureBorder.layoutWidth + 3);
	}

	public function preventMouseDown(event:MouseEvent, dispatchOpenEvent:Boolean = true):Boolean
	{
		if (isDisclosureIconClicked(event))
		{
			if (dispatchOpenEvent)
			{
				disclosureIconClickHandler(event);
			}
			return true;
		}
		else
		{
			return false;
		}
	}

	protected function disclosureIconClickHandler(event:MouseEvent):void
	{
		// stop this event from bubbling up because the click is for item selection
		// and clicking on the disclosureIcon doesn't select the items (only expands/closes them).
		event.stopPropagation();

		if (Tree(owner).isOpening)
		{
			return;
		}

		var open:Boolean = _listData.open;
		_listData.open = !open;
		Tree(owner).dispatchTreeEvent(TreeEvent.ITEM_OPENING, data, this, event, !open, false);
	}

	public function get styleName():Object
	{
		return null;
	}

	public function set styleName(value:Object):void
	{
	}

	public function styleChanged(styleProp:String):void
	{
	}
}
}