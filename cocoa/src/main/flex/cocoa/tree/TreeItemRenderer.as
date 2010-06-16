package cocoa.tree
{
import cocoa.AbstractView;
import cocoa.LabelHelper;
import cocoa.border.MultipleBorder;
import cocoa.plaf.LookAndFeelProvider;

import flash.display.DisplayObject;
import flash.events.MouseEvent;

import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.treeClasses.TreeListData;
import mx.core.mx_internal;
import mx.events.TreeEvent;

use namespace mx_internal;

public class TreeItemRenderer extends AbstractView implements IListItemRenderer, IDropInListItemRenderer
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

		labelHelper = new LabelHelper(this, LookAndFeelProvider(owner.parent).laf.getFont("SmallSystemFont"));
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
		return _listData == null ? "?" : _listData.label;
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

		if (_listData.hasChildren)
		{
			var disclosureBorder:MultipleBorder = MultipleBorder(LookAndFeelProvider(owner.parent).laf.getBorder("Tree.disclosureIcon." + (_listData.open ? "open" : "close")));
			if (Tree(owner).isItemSelected(data))
			{
				disclosureBorder.stateIndex = 3;
			}
		}

//		if (_listData.open)
//		{
//			if (disclosureOpenIcon != null && disclosureOpenIcon.visible)
//			{
//				layoutDisclosureIcon(disclosureOpenIcon);
//			}
//		}
//		else if (disclosureCloseIcon != null && disclosureCloseIcon.visible)
//		{
//			layoutDisclosureIcon(disclosureCloseIcon);
//		}

		labelHelper.validate();
		labelHelper.moveByInsetsWithXOffseet(h, Tree(owner).$border.contentInsets, Tree(owner).$border.frameInsets, _listData.indent);
	}

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

	private function isDisclosureIconClicked(disclosureIcon:DisplayObject, event:MouseEvent):Boolean
	{
		return disclosureIcon != null && disclosureIcon.visible && disclosureIcon.hitTestPoint(event.stageX, event.stageY);
	}

	public function checkDisclosure(event:MouseEvent, dispatchOpenEvent:Boolean = true):Boolean
	{
		if (dispatchOpenEvent)
		{
//			if ((_listData.open && isDisclosureIconClicked(disclosureOpenIcon, event)) || isDisclosureIconClicked(disclosureCloseIcon, event))
//			{
//				disclosureIconClickHandler(event);
//				return true;
//			}
//			else
//			{
				return false;
//			}
		}

		return false;
//		return isDisclosureIconClicked(disclosureOpenIcon, event) || isDisclosureIconClicked(disclosureCloseIcon, event);
	}

	protected function layoutDisclosureIcon(disclosureIcon:DisplayObject):void
	{
		disclosureIcon.x = _listData.indent;
		disclosureIcon.y = 2;
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