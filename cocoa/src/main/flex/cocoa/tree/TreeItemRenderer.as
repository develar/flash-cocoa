package cocoa.tree
{
import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;

import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.treeClasses.TreeListData;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.TreeEvent;

use namespace mx_internal;

public class TreeItemRenderer extends UIComponent implements IListItemRenderer, IDropInListItemRenderer
{
	private static const LABEL_TEXT_FORMAT:ElementFormat = new ElementFormat(new FontDescription("Lucida Grande, Segoe UI"), 11);

	protected var labelChanged:Boolean;

	protected var disclosureOpenIcon:DisplayObject;
	protected var disclosureCloseIcon:DisplayObject;

	protected var icon:DisplayObject;

	private var labelTextBlock:TextBlock;
	private var labelTextElement:TextElement;
	private var labelTexLine:TextLine;

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
		labelChanged = true;
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
			$addChild(icon);
		}

		if (labelTextBlock == null)
		{
			labelTextElement = new TextElement(null, labelTextFormat);
			labelTextBlock = new TextBlock(labelTextElement);
		}
	}

	protected function get labelTextFormat():ElementFormat
	{
		return LABEL_TEXT_FORMAT;
	}

	override protected function measure():void
	{
		super.measure();

		validateLabel();

		// icon size 16, horizontal gap 0
		measuredWidth = _listData == null?32: _listData.indent + 32 + labelTexLine.textWidth;
		measuredHeight = 20;
	}

	override protected function commitProperties():void
	{
		super.commitProperties();

		if (listDataChanged)
		{
			listDataChanged = false;

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
		if(w == 0 || h == 0)
		{
			return;
		}
		var itemX:Number = _listData.indent + 16;
		icon.x = itemX;
		itemX += 16;

		validateLabel();
		labelTexLine.x = itemX + 1;
		labelTexLine.y = h - 5;
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

	private function validateLabel():void
	{
		if (labelChanged)
		{
			labelChanged = false;
			if (labelTexLine != null)
			{
				$removeChild(labelTexLine);
				labelTextBlock.releaseLines(labelTexLine, labelTexLine);
			}
			if (_listData.label != null)
			{
				labelTextElement.text = _listData.label;
				labelTexLine = labelTextBlock.createTextLine();
				$addChild(labelTexLine);
			}
		}
	}
}
}