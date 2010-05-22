package cocoa.plaf.aqua
{
import cocoa.Insets;
import cocoa.View;
import cocoa.plaf.AbstractBorder;

import flash.display.Graphics;

public class TextInputBorder extends AbstractBorder
{
	private static const CONTENT_INSETS:Insets = new Insets(2, 3, 2, 2);

	public function TextInputBorder()
	{
		super();

		_contentInsets = CONTENT_INSETS;
	}

	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		g.lineStyle(1, 0xbebebe);
		g.beginFill(0x373737, 0.95);
		g.drawRect(0.5, 0.5, w - 1, h - 1);
		g.endFill();

		g.lineStyle(1, 0x404040);
		g.moveTo(1, 1);
		g.lineTo(w - 2, 1);

		g.moveTo(h - 2, 1);
		g.lineTo(h - 2, 1);
	}

	override public function get layoutHeight():Number
	{
		return 19;
	}
}
}