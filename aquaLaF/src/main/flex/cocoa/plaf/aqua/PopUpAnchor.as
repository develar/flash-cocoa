package cocoa.plaf.aqua
{
import cocoa.BorderedDataGroup;
import cocoa.Insets;
import cocoa.PopUpButton;
import cocoa.plaf.PopUpAnchor;

import flash.display.Stage;
import flash.geom.Point;

public class PopUpAnchor extends cocoa.plaf.PopUpAnchor
{
	private static const STAGE_MARGIN:Number = 6;
	private static const BOTTOM_STAGE_MARGIN:Number = 10;

	override protected function setPopUpPosition():void
    {
		var popUpButton:PopUpButton = PopUpButton(_popUpParent.parent);
		var borderedDataGroup:BorderedDataGroup = BorderedDataGroup(_popUp);
		var selectedItemRenderer:MenuItemRenderer = MenuItemRenderer(borderedDataGroup.getElementAt(popUpButton.selectedIndex));

		var stage:Stage = _popUp.stage;

		var listBorderContentInsets:Insets = borderedDataGroup.border.contentInsets;
		sharedPoint.x = - (listBorderContentInsets.left + selectedItemRenderer.labelLeftMargin) + PopUpOpenButtonSkin(popUpButton.openButton.skin).labelLeftMargin;
		sharedPoint.y = - listBorderContentInsets.top - selectedItemRenderer.baselinePosition + popUpButton.baselinePosition - (selectedItemRenderer.height * popUpButton.selectedIndex);
//		sharedPoint.x = 50;
//		sharedPoint.y = 20;
		var globalPosition:Point = _popUpParent.localToGlobal(sharedPoint);

		var x:Number = globalPosition.x;
		if (x < STAGE_MARGIN)
		{
			x = STAGE_MARGIN;
		}
		else
		{
			var maxX:Number = stage.stageWidth - STAGE_MARGIN - _popUp.width;
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
			var maxY:Number = stage.stageHeight - BOTTOM_STAGE_MARGIN - _popUp.height;
			if (y > maxY)
			{
				y = maxY;
			}
		}

		borderedDataGroup.move(x, y);
	}
}
}