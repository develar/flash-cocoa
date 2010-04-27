package cocoa
{
import cocoa.sidebar.events.SidebarEvent;

import flash.events.MouseEvent;
import flash.utils.Dictionary;

import spark.components.supportClasses.TextBase;

use namespace ui;

public class Panel extends Window
{
	protected static const _skinParts:Dictionary = new Dictionary();
	_skinParts.minimizeButton = 0;
	_skinParts.closeSideButton = 0;
	override protected function get skinParts():Dictionary
	{
		return _skinParts;
	}

	ui var titleDisplay:TextBase;

	ui var minimizeButton:PushButton;
	ui var closeSideButton:PushButton;

	ui function minimizeButtonAdded():void
	{
		minimizeButton.addEventListener(MouseEvent.CLICK, minimizeButtonActionHandler);
	}

	ui function closeSideButtonAdded():void
	{
		closeSideButton.addEventListener(MouseEvent.CLICK, closeSideButtonClickHandler);
	}

	private function minimizeButtonActionHandler(event:MouseEvent):void
	{
		dispatchEvent(new SidebarEvent(SidebarEvent.HIDE_PANE));
	}

	private function closeSideButtonClickHandler(event:MouseEvent):void
	{
		dispatchEvent(new SidebarEvent(SidebarEvent.HIDE_SIDE));
	}

	override protected function get defaultLaFPrefix():String
	{
		return "Panel";
	}
}
}