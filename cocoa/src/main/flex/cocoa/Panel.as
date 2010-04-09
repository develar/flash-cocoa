package cocoa
{
import cocoa.sidebar.events.SidebarEvent;

import flash.events.MouseEvent;
import flash.utils.Dictionary;

import mx.core.IVisualElement;

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

	ui var minimizeButton:IVisualElement;
	ui var closeSideButton:IVisualElement;

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

	override protected function get defaultLaFPrefix():String
	{
		return "Panel";
	}
}
}