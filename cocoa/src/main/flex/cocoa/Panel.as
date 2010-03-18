package cocoa
{
import cocoa.sidebar.events.SidebarEvent;

import flash.events.MouseEvent;

import mx.core.IVisualElement;

import spark.components.supportClasses.TextBase;

use namespace ui;

public class Panel extends Window
{
	ui var titleDisplay:TextBase;

	ui var minimizeButton:IVisualElement;
	ui var closeSideButton:IVisualElement;

	public function Panel()
	{
		super();

		skinParts.minimizeButton = 0;
		skinParts.closeSideButton = 0;
	}

	ui function minimizeButtonAdded():void
	{
		minimizeButton.addEventListener(MouseEvent.CLICK, minimizeButtonClickHandler);
	}

	ui function minimizeButtonRemoved():void
	{
		minimizeButton.removeEventListener(MouseEvent.CLICK, minimizeButtonClickHandler);
	}

	ui function closeSideButtonAdded():void
	{
		closeSideButton.addEventListener(MouseEvent.CLICK, closeSideButtonClickHandler);
	}

	ui function closeSideButtonRemoved():void
	{
		closeSideButton.removeEventListener(MouseEvent.CLICK, closeSideButtonClickHandler);
	}

	private function minimizeButtonClickHandler(event:MouseEvent):void
	{
		dispatchEvent(new SidebarEvent(SidebarEvent.HIDE_PANE));
	}

	private function closeSideButtonClickHandler(event:MouseEvent):void
	{
		dispatchEvent(new SidebarEvent(SidebarEvent.HIDE_SIDE));
	}

	override public function get stylePrefix():String
	{
		return "Panel";
	}
}
}