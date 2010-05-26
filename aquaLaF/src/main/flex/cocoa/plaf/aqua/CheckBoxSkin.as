package cocoa.plaf.aqua
{
import cocoa.AbstractButton;
import cocoa.CellState;
import cocoa.plaf.Scale1BitmapBorder;
import cocoa.plaf.basic.PushButtonSkin;

public class CheckBoxSkin extends cocoa.plaf.basic.PushButtonSkin
{
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		Scale1BitmapBorder(border).bitmapIndex = calculateBitmapIndex();
		alpha = enabled ? 1 : 0.5;

		super.updateDisplayList(border.layoutWidth, h);
	}

	protected function calculateBitmapIndex():int
	{
		return AbstractButton(myComponent).isMouseDown ? (myComponent.state == CellState.ON ? 1 : 3) : (myComponent.state == CellState.ON ? 2 : 0);
	}

	override protected function measure():void
	{
		if (labelHelper == null || !labelHelper.hasText)
		{
			measuredWidth = border.layoutWidth;
			measuredHeight = border.layoutHeight;
		}
		else
		{
			super.measure();
		}
	}
}
}