package cocoa.plaf.aqua
{
import cocoa.CellState;
import cocoa.plaf.basic.PushButtonSkin;
import cocoa.plaf.Scale3EdgeHBitmapBorder;

public class PushButtonSkin extends cocoa.plaf.basic.PushButtonSkin
{
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		Scale3EdgeHBitmapBorder(border).bitmapIndex = (enabled ? (myComponent.state == CellState.OFF ? 0 : 1) : 2) << 1;

		super.updateDisplayList(w, h);
	}

	public function get labelLeftMargin():Number
	{
		return border.contentInsets.left + border.frameInsets.left;
	}
}
}