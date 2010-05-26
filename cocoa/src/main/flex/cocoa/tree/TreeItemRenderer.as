package cocoa.tree
{
import cocoa.AbstractView;
import cocoa.Application;
import cocoa.LabelHelper;
import cocoa.plaf.MXMLSkin;

import flash.display.DisplayObject;
import flash.events.MouseEvent;

import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.treeClasses.TreeListData;
import mx.core.FlexGlobals;
import mx.core.mx_internal;
import mx.events.TreeEvent;

use namespace mx_internal;

public class TreeItemRenderer extends AbstractView implements IListItemRenderer, IDropInListItemRenderer
{
	protected var disclosureOpenIcon:DisplayObject;
	protected var disclosureCloseIcon:DisplayObject;

	protected var icon:DisplayObject;

	protected var labelHelper:LabelHelper;

	private var listDataChanged:Boolean;

	private var _listData:TreeListData;
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
		
		invalidateProperties();
		invalidateDisplayList();
	}

	override protected function createChildren():void
	{
		super.createChildren();

		if (icon == null)
		{
			var iconClass:Class = Tree(owner).getStyle("pageIcon");
			icon = new iconClass();
			icon.y = 2;
			addDisplayObject(icon);
		}

		labelHelper = new LabelHelper(this, MXMLSkin(Application(FlexGlobals.topLevelApplication).getSubviewAt(0)).laf.getFont("SystemFont"));
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

			if (_listData.hasChildren ? Tree(owner).dataDescriptor.hasChildren(_listData.item) : false)
			{
				if (_listData.open)
				{
					if (disclosureCloseIcon != null && disclosureCloseIcon.visible)
					{
						disclosureCloseIcon.visible = false;
					}

					if (disclosureOpenIcon == null)
					{
						disclosureOpenIcon = createDisclosureIcon(_listData.disclosureIcon);
					}
					else if (!disclosureOpenIcon.visible)
					{
						disclosureOpenIcon.visible = true;
					}

					disclosureOpenIcon.x = _listData.indent;
				}
				else
				{
					if (disclosureOpenIcon != null && disclosureOpenIcon.visible)
					{
						disclosureOpenIcon.visible = false;
					}

					if (disclosureCloseIcon == null)
					{
						disclosureCloseIcon = createDisclosureIcon(_listData.disclosureIcon);
					}
					else if (!disclosureCloseIcon.visible)
					{
						disclosureCloseIcon.visible = true;
					}

					disclosureCloseIcon.x = _listData.indent;
				}
			}
			else
			{
				if (disclosureOpenIcon != null)
				{
					disclosureOpenIcon.visible = false;
				}
				if (disclosureCloseIcon != null)
				{
					disclosureCloseIcon.visible = false;
				}
			}
		}
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		if (w == 0 || h == 0)
		{
			return;
		}
		var itemX:Number = _listData.indent + 16;
		icon.x = itemX;
		itemX += 16;

		labelHelper.validate();
		labelHelper.move(itemX + 1, h - 5);
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

	private function createDisclosureIcon(clazz:Class):DisplayObject
	{
		var disclosureIcon:DisplayObject = new clazz();
		disclosureIcon.x = _listData.indent;
		disclosureIcon.y = 2;

		addChild(disclosureIcon);

		disclosureIcon.addEventListener(MouseEvent.CLICK, disclosureIconClickHandler);

		return disclosureIcon;
	}

	private function disclosureIconClickHandler(event:MouseEvent):void
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
		Tree(owner).dispatchTreeEvent(TreeEvent.ITEM_OPENING, data, this, event, !open);
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