package cocoa.plaf.aqua
{
import cocoa.AbstractButton;
import cocoa.CellState;
import cocoa.Insets;
import cocoa.TextInsets;
import cocoa.border.Scale1BitmapBorder;
import cocoa.plaf.basic.PushButtonSkin;

import flash.display.Graphics;

public class CheckBoxSkin extends cocoa.plaf.basic.PushButtonSkin
{
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		Scale1BitmapBorder(border).stateIndex = calculateBitmapIndex();
		alpha = enabled ? 1 : 0.5;

		if (labelHelper != null && labelHelper.hasText)
		{
			if (border != null && (!isNaN(explicitWidth) || !isNaN(percentWidth)))
			{
				var titleInsets:Insets = border.contentInsets;
				labelHelper.adjustWidth(w - titleInsets.left - (titleInsets is TextInsets ? TextInsets(titleInsets).truncatedTailMargin : titleInsets.right));
			}

			labelHelper.validate();
			labelHelper.moveByInsets(h, border.contentInsets, border.frameInsets);
		}

		var g:Graphics = graphics;
		g.clear();
		border.draw(this, g, border.layoutWidth, h);
	}

	protected function calculateBitmapIndex():int
	{
		return AbstractButton(myComponent).isMouseDown ? (myComponent.state == CellState.ON ? 1 : 3) : (myComponent.state == CellState.ON ? 2 : 0);
	}
}
}