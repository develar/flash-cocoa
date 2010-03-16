package cocoa.plaf.aqua
{
import cocoa.ButtonState;
import cocoa.plaf.AbstractPushButtonSkin;
import cocoa.plaf.Scale3HBitmapBorder;

public class PushButtonSkin extends AbstractPushButtonSkin
{
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		Scale3HBitmapBorder(border).bitmapIndex = (enabled ? (hostComponent.state == ButtonState.off ? 0 : 1) : 2) << 1;

		super.updateDisplayList(w, h);
	}
}
}