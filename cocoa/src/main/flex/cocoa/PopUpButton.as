package cocoa
{
import mx.collections.IList;
import mx.core.mx_internal;

import spark.components.DataGroup;
import spark.components.supportClasses.ButtonBase;
import spark.utils.LabelUtil;

use namespace mx_internal;
use namespace ui;

/**
 * http://developer.apple.com/Mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGControls/XHIGControls.html#//apple_ref/doc/uid/TP30000359-TPXREF132
 */
public class PopUpButton extends AbstractView
{
	ui var openButton:ButtonBase;
	ui var dataGroup:DataGroup;

	public function PopUpButton()
	{
		super();

		skinParts.dataGroup = 0;
		requireSelection = true;
	}

	private var _dataProvider:IList;
	public function set dataProvider(value:IList):void
	{
		if (value != _dataProvider)
		{
			_dataProvider = value;
		}
	}

	ui function dataGroupAdded():void
	{
		dataGroup.dataProvider = _dataProvider;
	}

	override mx_internal function updateLabelDisplay(displayItem:* = undefined):void
	{
		if (openButton != null)
		{
			if (displayItem === undefined)
			{
				displayItem = selectedItem;
			}

			PushButton(openButton).label = LabelUtil.itemToLabel(displayItem, labelField, labelFunction);
		}
	}
}
}