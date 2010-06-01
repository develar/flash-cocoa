package cocoa.plaf.aqua
{
import cocoa.CellState;
import cocoa.plaf.AbstractMultipleBitmapBorder;
import cocoa.plaf.basic.PushButtonSkin;

public class PushButtonSkin extends cocoa.plaf.basic.PushButtonSkin
{
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		AbstractMultipleBitmapBorder(border).stateIndex = enabled ? (myComponent.state == CellState.OFF ? 0 : 1) : 2;

		super.updateDisplayList(w, h);
	}

	public function get labelLeftMargin():Number
	{
		return border.contentInsets.left + border.frameInsets.left;
	}
}
}