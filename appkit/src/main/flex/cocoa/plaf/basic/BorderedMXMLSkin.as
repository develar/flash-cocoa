package cocoa.plaf.basic
{
import cocoa.Border;

import flash.display.Graphics;

public class BorderedMXMLSkin extends MXMLSkin
{
	private var border:Border;

	override protected function createChildren():void
	{
		super.createChildren();

		border = _laf.getBorder(component.lafKey + ".b", false);
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