package org.flyti.view
{
import org.flyti.view;
import org.flyti.view.sidebar.events.SidebarEvent;

import flash.events.MouseEvent;

import mx.core.IVisualElement;

import spark.components.supportClasses.TextBase;

use namespace view;

public class Panel extends Window
{
	view var titleDisplay:TextBase;

	view var minimizeButton:IVisualElement;
	view var closeSideButton:IVisualElement;

	public function Panel()
	{
		super();

		skinParts.minimizeButton = 0;
		skinParts.closeSideButton = 0;
	}

	view function minimizeButtonAdded():void
	{
		minimizeButton.addEventListener(MouseEvent.CLICK, minimizeButtonClickHandler);
	}

	view function minimizeButtonRemoved():void
	{
		minimizeButton.removeEventListener(MouseEvent.CLICK, minimizeButtonClickHandler);
	}

	view function closeSideButtonAdded():void
	{
		closeSideButton.addEventListener(MouseEvent.CLICK, closeSideButtonClickHandler);
	}

	view function closeSideButtonRemoved():void
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
}
}