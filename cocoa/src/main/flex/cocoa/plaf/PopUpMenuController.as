package cocoa.plaf
{
import cocoa.ItemMouseSelectionMode;
import cocoa.Menu;
import cocoa.ui;

import flash.display.DisplayObject;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.getTimer;

import mx.managers.PopUpManager;

import spark.components.IItemRenderer;

use namespace ui;

public class PopUpMenuController
{
	private const MOUSE_CLICK_INTERVAL:int = 400;

	protected static const sharedPoint:Point = new Point();
	
	protected var openButton:DisplayObject;
	protected var menu:Menu;
	private var laf:LookAndFeel;

	private var mouseDownTime:int = -1;

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

		menu.itemGroup.mouseSelectionMode = ItemMouseSelectionMode.none;

		openButton.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
		openButton.stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);

		mouseDownTime = getTimer();
	}

	protected function close():void
	{
		openButton.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
		openButton.stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);
		PopUpManager.removePopUp(menu.skin);
	}

	protected function setPopUpPosition():void
    {
		throw new Error("abstract");
	}

	private function stageMouseUpHandler(event:MouseEvent):void
	{
		// menu.itemGroup, а не скин — проверка на border (как в Cocoa — можно кликнуть на border и при этом и меню не будет скрыто, и выделенный item не изменится)
		if (!menu.skin.hitTestPoint(event.stageX, event.stageY))
		{
			close();
		}
		else if (event.target != menu.skin && event.target != menu.itemGroup)
		{
			menu.selectedIndex = IItemRenderer(event.target).itemIndex;
			if (mouseDownTime == -1 || (getTimer() - mouseDownTime) > MOUSE_CLICK_INTERVAL)
			{
				close();
			}
			else
			{
				mouseDownTime = -1;
			}
		}
	}

	private function stageMouseDownHandler(event:MouseEvent):void
	{
		if (!menu.skin.hitTestPoint(event.stageX, event.stageY))
		{
			close();
		}
	}
}
}