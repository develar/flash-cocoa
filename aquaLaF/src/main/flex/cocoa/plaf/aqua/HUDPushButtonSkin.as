package cocoa.plaf.aqua
{
import cocoa.CellState;
import cocoa.border.MultipleBorder;
import cocoa.plaf.basic.PushButtonSkin;

public class HUDPushButtonSkin extends cocoa.plaf.basic.PushButtonSkin
{
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		MultipleBorder(border).stateIndex = myComponent.state == CellState.OFF ? 0 : 1;

		super.updateDisplayList(w, h);
	}
}
}