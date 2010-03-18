package cocoa.plaf.aqua
{
import cocoa.Border;
import cocoa.View;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;

internal class SeparatorMenuItemBorder extends MenuItemBorder implements Border
{
	public function SeparatorMenuItemBorder()
	{
		super(EMPTY_CONTENT_INSETS);
	}

	override public function get layoutHeight():Number
	{
		return 12;
	}

	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		super.draw(view, g, w, h);

		g.moveTo(1, 5);
		g.lineStyle(1, 0xe3e3e3, 243 / 255, false, LineScaleMode.NORMAL, CapsStyle.NONE);
		g.lineTo(w - 1, 5);
	}
}
}