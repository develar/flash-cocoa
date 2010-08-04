package cocoa.plaf.aqua
{
import cocoa.Insets;
import cocoa.plaf.basic.MenuSkin;
import cocoa.plaf.basic.PopUpMenuController;
import cocoa.plaf.basic.PushButtonSkin;
import cocoa.ui;

import flash.display.Stage;
import flash.geom.Point;

use namespace ui;

public class PopUpMenuController extends cocoa.plaf.basic.PopUpMenuController
{
	private static const STAGE_MARGIN:Number = 6;
	private static const BOTTOM_STAGE_MARGIN:Number = 10;

	/**
	 * если правая граница меню расположена более чем на 7 px левее чем край pop up button — то мы увеличиваем ее
	 */
	private static const MIN_RIGHT_MARGIN_FROM_OPEN_BUTTON:Number = 7;

	override protected function setPopUpPosition():void
    {
		var selectedItemRenderer:MenuItemRenderer = MenuItemRenderer(menu.itemGroup.getElementAt(popUpButton.selectedIndex));
		var popUpButtonSkin:cocoa.plaf.basic.PushButtonSkin = cocoa.plaf.basic.PushButtonSkin(popUpButton.skin);
		var stage:Stage = popUpButtonSkin.stage;
		var menuSkin:MenuSkin = MenuSkin(menu.skin);
		var menuBorderContentInsets:Insets = menuSkin.border.contentInsets;
		sharedPoint.x = - (menuBorderContentInsets.left + selectedItemRenderer.labelLeftMargin) + popUpButtonSkin.labelLeftMargin;
		sharedPoint.y = - menuBorderContentInsets.top - selectedItemRenderer.baselinePosition + popUpButtonSkin.baselinePosition - selectedItemRenderer.y;
//		sharedPoint.x = 250;
//		sharedPoint.y = 20;
		var globalPosition:Point = popUpButtonSkin.localToGlobal(sharedPoint);

		var x:Number = globalPosition.x;
		if (x < STAGE_MARGIN)
		{
			x = STAGE_MARGIN;
		}
		else
		{
			var maxX:Number = stage.stageWidth - STAGE_MARGIN - menuSkin.width;
			if (x > maxX)
			{
				x = maxX;
			}
			else
			{
				var widthAdjustment:Number = popUpButtonSkin.width - menuSkin.width - sharedPoint.x - MIN_RIGHT_MARGIN_FROM_OPEN_BUTTON;
				if (widthAdjustment > 0)
				{
					menuSkin.width = menuSkin.width + widthAdjustment;
				}
			}
		}

		var y:Number = globalPosition.y;
		if (y < STAGE_MARGIN)
		{
			y = STAGE_MARGIN;
		}
		else
		{
			var maxY:Number = stage.stageHeight - BOTTOM_STAGE_MARGIN - menuSkin.height;
			if (y > maxY)
			{
				y = maxY;
			}
		}

		menuSkin.move(x, y);
	}
}
}