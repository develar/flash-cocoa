package cocoa.plaf.aqua
{
import cocoa.View;
import cocoa.plaf.AbstractBorder;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;

public class SeparatorBorder extends AbstractBorder
{
	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		g.lineStyle(1, 0xffffff, 0.3, false, LineScaleMode.NORMAL, CapsStyle.NONE);
		g.moveTo(0, h);
		g.lineTo(w, h);
	}

	override public function get layoutWidth():Number
	{
		return -100;
	}

	override public function get layoutHeight():Number
	{
		return 1;
	}
}
}