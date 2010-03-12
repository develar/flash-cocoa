package cocoa.plaf.aqua
{
import cocoa.Border;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;

import mx.core.UIComponent;

internal class SeparatorMenuItemBorder extends MenuItemBorder implements Border
{
	override public function get layoutHeight():Number
	{
		return 12;
	}

	override public function draw(object:UIComponent, g:Graphics, w:Number, h:Number):void
	{
		super.draw(object, g, w, h);

		g.moveTo(1, 5);
		g.lineStyle(1, 0xe3e3e3, 0.95, false, LineScaleMode.NORMAL, CapsStyle.NONE);
		g.lineTo(w - 1, 5);
	}
}
}