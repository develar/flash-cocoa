package cocoa.plaf.aqua
{
import cocoa.AbstractBorder;
import cocoa.Border;
import cocoa.View;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;

internal class SeparatorMenuItemBorder extends AbstractBorder implements Border
{
	override public function get layoutHeight():Number
	{
		return 12;
	}

	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		g.beginFill(0xffffff, 242 / 255);
		g.drawRect(0, 0, w, 5);
		g.endFill();

		g.beginFill(0xffffff, 242 / 255);
		g.drawRect(0, 6, w, 6);
		g.endFill();

		g.moveTo(0, 5.5);
		g.lineStyle(1, 0xffffff, 242 / 255, false, LineScaleMode.NORMAL, CapsStyle.NONE);
		g.lineTo(1, 5.5);

		g.lineStyle(1, 0xe3e3e3, 243 / 255, false, LineScaleMode.NORMAL, CapsStyle.NONE);
		g.lineTo(w - 1, 5.5);

		g.lineStyle(1, 0xffffff, 242 / 255, false, LineScaleMode.NORMAL, CapsStyle.NONE);
		g.lineTo(w, 5.5);
	}
}
}