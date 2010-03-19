package cocoa.plaf
{
import cocoa.Menu;

import flash.display.DisplayObject;
import flash.events.MouseEvent;

import mx.managers.PopUpManager;

public class PopUpMenuController
{
	private var openButton:DisplayObject;
	private var menu:Menu;
	private var laf:LookAndFeel;

	public function PopUpMenuController(openButton:DisplayObject, menu:Menu, laf:LookAndFeel)
	{
		this.openButton = openButton;
		this.menu = menu;
		this.laf = laf;
		addHandlers();
	}

	private function addHandlers():void
	{
		openButton.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}

	private function mouseDownHandler(event:MouseEvent):void
	{
		var menuSkin:Skin = menu.skin;
		if (menuSkin == null)
		{
			menuSkin = menu.createView(laf);
		}
		PopUpManager.addPopUp(menuSkin, openButton, false);

		openButton.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
	}

	private function stageMouseUpHandler(event:MouseEvent):void
	{

	}
}
}