package cocoa.plaf
{
import cocoa.Menu;

import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.managers.PopUpManager;

public class PopUpMenuController
{
	protected static const sharedPoint:Point = new Point();
	
	protected var openButton:DisplayObject;
	protected var menu:Menu;
	private var laf:LookAndFeel;

	public function initialize(openButton:DisplayObject, menu:Menu, laf:LookAndFeel):void
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
		event.stopImmediatePropagation();

		var menuSkin:Skin = menu.skin;
		if (menuSkin == null)
		{
			menuSkin = menu.createView(laf);
		}
		PopUpManager.addPopUp(menuSkin, openButton, false);
		setPopUpPosition();

		openButton.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
		openButton.stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);
	}

	protected function close():void
	{
		PopUpManager.removePopUp(menu.skin);
	}

	protected function setPopUpPosition():void
    {
		throw new Error("abstract");
	}

	private function stageMouseUpHandler(event:MouseEvent):void
	{
	}

	private function stageMouseDownHandler(event:MouseEvent):void
	{
		openButton.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
		openButton.stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);
		close();
	}
}
}