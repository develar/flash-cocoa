package cocoa.plaf.basic
{
import cocoa.Border;
import cocoa.plaf.AbstractSkin;

import flash.display.Graphics;

public class SeparatorSkin extends AbstractSkin
{
	private var border:Border;

	override protected function createChildren():void
	{
		super.createChildren();

		border = laf.getBorder(component.lafPrefix + ".border");
	}

	override protected function measure():void
	{
		measuredWidth = isNaN(border.layoutWidth) ? 0 : border.layoutWidth;
		measuredHeight = isNaN(border.layoutHeight) ? 0 : border.layoutHeight;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		var g:Graphics = graphics;
		g.clear();
		border.draw(this, g, w, h);
	}
}
}