package cocoa.plaf.aqua
{
import cocoa.AbstractBorder;
import cocoa.Border;
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

internal class MenuItemBorder extends AbstractBorder implements Border
{
	public function MenuItemBorder(contentInsets:Insets)
	{
		_contentInsets = contentInsets;
	}

	override public function get layoutHeight():Number
	{
		return 18;
	}

	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		g.beginFill(0xffffff, 242 / 255);
		g.drawRect(0, 0, w, h);
		g.endFill();
	}
}
}