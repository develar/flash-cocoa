package cocoa.plaf
{
import cocoa.Menu;
import cocoa.PopUpButton;
import cocoa.ui;

import flash.display.DisplayObject;
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.ui.Keyboard;
import flash.utils.getTimer;

import mx.managers.PopUpManager;

import spark.components.IItemRenderer;

use namespace ui;

public class PopUpMenuController extends ListController
{
	private const MOUSE_CLICK_INTERVAL:int = 400;

	protected static const sharedPoint:Point = new Point();
	
	protected var popUpButton:PopUpButton;
	protected var menu:Menu;
	private var laf:LookAndFeel;

	private var mouseDownTime:int = -1;

	public function initialize(popUpButton:PopUpButton, menu:Menu, laf:LookAndFeel):void
	{
		this.popUpButton = popUpButton;
		this.menu = menu;
		this.laf = laf;
		addHandlers();

		flags |= HIGHLIGHTABLE;
	}

	override protected function addHandlers():void
	{
		popUpButton.skin.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		popUpButton.skin.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
	}

	override protected function keyDownHandler(event:KeyboardEvent):void
	{
		super.keyDownHandler(event);

		if (event.preventDefault())
		{
			return;
		}

		switch (event.keyCode)
		{
			case Keyboard.ESCAPE:
			{
				if (menu.skin != null && DisplayObject(menu.skin).parent != null)
				{
					event.preventDefault();
					close();
				}
			}
			break;

			case Keyboard.ENTER:
			case Keyboard.SPACE:
			{
				if (highlightedRenderer != null)
				{
					popUpButton.selectedIndex = highlightedRenderer.itemIndex;
				}
				close();
			}
		}
	}

	private function mouseDownHandler(event:MouseEvent):void
	{
		var popUpButtonSkin:DisplayObject = DisplayObject(popUpButton.skin);
		var menuSkin:Skin = menu.skin;
		if (menuSkin == null)
		{
			menuSkin = menu.createView(laf);
		}
		PopUpManager.addPopUp(menuSkin, popUpButtonSkin, false);
		setPopUpPosition();

		itemGroup = menu.itemGroup;
		super.addHandlers();

		popUpButtonSkin.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
		popUpButtonSkin.stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);

		mouseDownTime = getTimer();
	}

	protected function close():void
	{
		var stage:Stage = DisplayObject(popUpButton.skin).stage;
		stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
		stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDownHandler);
		PopUpManager.removePopUp(menu.skin);
	}

	protected function setPopUpPosition():void
    {
		throw new Error("abstract");
	}

	private function stageMouseUpHandler(event:MouseEvent):void
	{
		// проверка на border (как в Cocoa — можно кликнуть на border, и при этом и меню не будет скрыто, и выделенный item не изменится)
		if (!menu.skin.hitTestPoint(event.stageX, event.stageY))
		{
			// для pop up button работает такое же правило щелчка, как и для menu border
			if (!popUpButton.skin.hitTestPoint(event.stageX, event.stageY))
			{
				mouseDownTime = -1;
			}
		}
		else if (event.target != menu.skin && event.target != itemGroup)
		{
			popUpButton.selectedIndex = IItemRenderer(event.target).itemIndex;
		}
		else
		{
			return;
		}

		if (mouseDownTime == -1 || (getTimer() - mouseDownTime) > MOUSE_CLICK_INTERVAL)
		{
			close();
		}
		else
		{
			mouseDownTime = -1;
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