package cocoa.plaf.aqua
{
import cocoa.AbstractBorder;
import cocoa.Border;

import flash.display.Graphics;

import mx.core.UIComponent;

internal class MenuItemBorder extends AbstractBorder implements Border
{
	public function get layoutHeight():Number
	{
		return 18;
	}

	public function draw(object:UIComponent, g:Graphics, w:Number, h:Number):void
	{
		g.beginFill(0xffffff, 0.94);
		g.drawRect(0, 0, w, h);
		g.endFill();
	}
}
}