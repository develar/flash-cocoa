package org.flyti.aqua
{
import mx.core.ClassFactory;
import mx.core.IFactory;

import org.flyti.view.BorderedDataGroup;
import org.flyti.view.LightUIComponent;
import cocoa.PopUpButton;
import cocoa.PushButton;

import spark.layouts.HorizontalAlign;
import spark.layouts.VerticalLayout;

public class PopUpButtonSkin extends LightUIComponent
{
	public var openButton:PushButton;
	private var dropDown:BorderedDataGroup;
	private var dataGroup:BorderedDataGroup;
	private var popUpAnchor:PopUpAnchor;

	private static const menuItemRendererFactory:IFactory = new ClassFactory(MenuItemRenderer);

	override protected function createChildren():void
	{
		if (openButton == null)
		{
			openButton = new PushButton();
			openButton.setStyle("skinClass", PopUpOpenButtonSkin);
			addChild(openButton);
		}
	}

	private function createDropDownAndPopUpAnchor():void
	{
		dataGroup = new BorderedDataGroup();
		dropDown = dataGroup;

		dataGroup.border = AquaBorderFactory.getPopUpMenuBorder();
		dataGroup.itemRenderer = menuItemRendererFactory;
		var dataGroupLayout:VerticalLayout = new VerticalLayout();
		dataGroupLayout.gap = 0;
		dataGroupLayout.horizontalAlign = HorizontalAlign.CONTENT_JUSTIFY;
		dataGroup.layout = dataGroupLayout;

		popUpAnchor = new PopUpAnchor();
		popUpAnchor.popUp = dropDown;
		popUpAnchor.popUpParent = this;

		PopUpButton(parent).skinPartAdded("dropDown", dropDown);
		PopUpButton(parent).skinPartAdded("dataGroup", dataGroup);
	}

	private var _currentState:String;
	override public function get currentState():String
    {
        return _currentState;
    }
    override public function set currentState(value:String):void
    {
        if (value != _currentState)
		{
			_currentState = value;
			if (_currentState == "open")
			{
				if (popUpAnchor == null)
				{
					createDropDownAndPopUpAnchor();
				}
				popUpAnchor.displayPopUp = true;
			}
			else if (popUpAnchor != null)
			{
				popUpAnchor.displayPopUp = false;
			}
			invalidateDisplayList();
		}
    }

	override protected function measure():void
	{
		measuredMinWidth = openButton.measuredMinHeight;
		measuredMinHeight = openButton.measuredMinHeight;

		measuredWidth = openButton.getExplicitOrMeasuredWidth();
		measuredHeight = openButton.getExplicitOrMeasuredHeight();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		openButton.setActualSize(openButton.getExplicitOrMeasuredWidth(), openButton.getExplicitOrMeasuredHeight());
	}

	override public function get baselinePosition():Number
	{
		return openButton.baselinePosition;
	}
}
}