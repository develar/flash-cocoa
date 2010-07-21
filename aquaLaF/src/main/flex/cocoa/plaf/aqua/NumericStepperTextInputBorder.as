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

	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		drawOuterBorder(g, w, h);
	}
}
}