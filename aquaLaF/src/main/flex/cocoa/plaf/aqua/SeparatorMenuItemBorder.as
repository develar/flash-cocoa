package cocoa.plaf.aqua
{
import cocoa.AbstractBorder;
import cocoa.Border;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;

import mx.core.UIComponent;

public class SeparatorMenuItemBorder extends AbstractBorder implements Border
{
	public function get layoutHeight():Number
	{
		return 12;
	}

	public function draw(object:UIComponent, g:Graphics, w:Number, h:Number):void
	{
		g.beginFill(0xffffff, 0.94);
		g.drawRect(0, 0, w, h);
		g.endFill();

		g.moveTo(1, 5);
		g.lineStyle(1, 0xe3e3e3, 95, false, LineScaleMode.NORMAL, CapsStyle.NONE);
		g.lineTo(w - 1, 5);
	}
}
}