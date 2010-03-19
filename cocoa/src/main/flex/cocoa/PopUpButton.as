package cocoa
{
import mx.collections.IList;

import spark.components.DataGroup;

use namespace ui;

/**
 * http://developer.apple.com/Mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGControls/XHIGControls.html#//apple_ref/doc/uid/TP30000359-TPXREF132
 */
public class PopUpButton extends AbstractComponent
{
	ui var dataGroup:DataGroup;

	public function PopUpButton()
	{
		super();

		skinParts.dataGroup = 0;
//		requireSelection = true;
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

//	override mx_internal function updateLabelDisplay(displayItem:* = undefined):void
//	{
//		if (openButton != null)
//		{
//			if (displayItem === undefined)
//			{
////				displayItem = selectedItem;
//			}
//
////			PushButton(openButton).label = LabelUtil.itemToLabel(displayItem, labelField, labelFunction);
//		}
//	}

	public function set labelFunction(labelFunction:Function):void
	{
//		_labelFunction = labelFunction;
	}

	public function get selectedItem():Object
	{
		return null;
	}

	override public function get lafPrefix():String
	{
		return "PopUpButton";
	}
}
}