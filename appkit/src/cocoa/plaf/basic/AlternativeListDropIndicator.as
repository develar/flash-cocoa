package cocoa.plaf.basic
{
import flash.display.Graphics;

import mx.skins.ProgrammaticSkin;

public class AlternativeListDropIndicator extends ProgrammaticSkin
{
    public const DRAW_LINE:String = "drawLine";
    public const DRAW_RECT:String = "drawRect";

    public var mode:String = DRAW_LINE;

    override protected function updateDisplayList(w:Number, h:Number):void
    {
        super.updateDisplayList(w, h);

        var g:Graphics = graphics;
        g.clear();

        if (mode == DRAW_RECT)
        {
            g.lineStyle(1, 0xA8C6EE);
            g.beginFill(0xA8C6EE, 0.3);
            g.drawRect(0, 0, w, h);
            g.endFill();
        }
        else
        {
            g.lineStyle(0.5, 0x2B333C);

            g.moveTo(0, 0);
		    g.lineTo(w, 0);

            g.moveTo(0, -2);
            g.lineTo(0, 3);

            g.moveTo(w, -2);
            g.lineTo(w, 3);
        }
    }
}
}