package cocoa.plaf.aqua
{
import cocoa.Insets;
import cocoa.plaf.MenuSkin;
import cocoa.plaf.PopUpMenuController;
import cocoa.ui;

import flash.display.Stage;
import flash.geom.Point;

use namespace ui;

public class PopUpMenuController extends cocoa.plaf.PopUpMenuController
{
	private static const STAGE_MARGIN:Number = 6;
	private static const BOTTOM_STAGE_MARGIN:Number = 10;

	override protected function setPopUpPosition():void
    {
		var selectedItemRenderer:MenuItemRenderer = MenuItemRenderer(menu.itemGroup.getElementAt(menu.selectedIndex));
		var stage:Stage = openButton.stage;
		var menuSkin:MenuSkin = MenuSkin(menu.skin);
		var menuBorderContentInsets:Insets = menuSkin.border.contentInsets;
		sharedPoint.x = - (menuBorderContentInsets.left + selectedItemRenderer.labelLeftMargin) + PushButtonSkin(openButton).labelLeftMargin;
		sharedPoint.y = - menuBorderContentInsets.top - selectedItemRenderer.baselinePosition + PushButtonSkin(openButton).baselinePosition - (selectedItemRenderer.height * menu.selectedIndex);
//		sharedPoint.x = 50;
//		sharedPoint.y = 20;
		var globalPosition:Point = openButton.localToGlobal(sharedPoint);

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