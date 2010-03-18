package cocoa.plaf
{
import cocoa.BorderedDataGroup;
import cocoa.PopUpButton;
import cocoa.PushButton;

import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalLayout;

public class PopUpButtonSkin extends AbstractSkin
{
	public var openButton:PushButton;
	private var dropDown:BorderedDataGroup;
	private var dataGroup:BorderedDataGroup;
	protected var popUpAnchor:PopUpAnchor;

	override protected function createChildren():void
	{
		if (openButton == null)
		{
			openButton = new PushButton();
//			openButton.setStyle("skinClass", laf.getUI("PopUpButton.openButton.skin"));
//			addChild(openButton);
		}
	}

	protected function createDropDownAndPopUpAnchor():void
	{
		dataGroup = new BorderedDataGroup();
		dropDown = dataGroup;

		dataGroup.border = getBorder("menuBorder");
		dataGroup.itemRenderer = laf.getFactory("PopUpButton.menuItemFactory");
		var dataGroupLayout:VerticalLayout = new VerticalLayout();
		dataGroupLayout.gap = 0;
		dataGroupLayout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
		dataGroup.layout = dataGroupLayout;

		popUpAnchor.popUp = dropDown;
		popUpAnchor.popUpParent = this;

		PopUpButton(parent).uiPartAdded("dropDown", dropDown);
		PopUpButton(parent).uiPartAdded("dataGroup", dataGroup);
	}

	private var _currentState:String;
//	override public function get currentState():String
//    {
//        return _currentState;
//    }
//    override public function set currentState(value:String):void
//    {
//        if (value != _currentState)
//		{
//			_currentState = value;
//			if (_currentState == "open")
//			{
//				if (popUpAnchor == null)
//				{
//					createDropDownAndPopUpAnchor();
//				}
//				popUpAnchor.displayPopUp = true;
//			}
//			else if (popUpAnchor != null)
//			{
//				popUpAnchor.displayPopUp = false;
//			}
//			invalidateDisplayList();
//		}
//    }

	override protected function measure():void
	{
//		measuredMinWidth = openButton.measuredMinHeight;
//		measuredMinHeight = openButton.measuredMinHeight;
//
//		measuredWidth = openButton.getExplicitOrMeasuredWidth();
//		measuredHeight = openButton.getExplicitOrMeasuredHeight();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
//		openButton.setActualSize(openButton.getExplicitOrMeasuredWidth(), openButton.getExplicitOrMeasuredHeight());
	}

//	override public function get baselinePosition():Number
//	{
//		return openButton.baselinePosition;
//	}
}
}