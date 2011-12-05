package cocoa.plaf.basic
{
import flash.display.Graphics;

import mx.skins.ProgrammaticSkin;

public class TransparentListDropIndicator extends ProgrammaticSkin
{
    public var direction:String = "horizontal";

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		var g:Graphics = graphics;

		g.clear();
		g.lineStyle(2, 0x2B333C, 0.0);

		// Line
		if (direction == "horizontal")
		{
		    g.moveTo(0, 0);
		    g.lineTo(w, 0);
        }
        else
        {
            g.moveTo(0, 0);
            g.lineTo(0, h);
        }
	}
}
}