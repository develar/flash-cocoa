package cocoa.plaf.aqua
{
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

public class NumericStepperTextInputBorder extends HUDTextInputBorder
{
	private static const CONTENT_INSETS:Insets = new Insets(4, 3, 4, 2);

	public function NumericStepperTextInputBorder()
	{
		super();

		_contentInsets = CONTENT_INSETS;
	}

	override public function get layoutHeight():Number
	{
		return 18;
	}

	override public function draw(g:Graphics, w:Number = NaN, h:Number = NaN, x:Number = 0, y:Number = 0, view:View = null):void
	{
		drawOuterBorder(g, w, h);
	}
}
}