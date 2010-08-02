package cocoa.colorPicker
{
import cocoa.Menu;
import cocoa.PopUpButton;

import org.flyti.util.ArrayList;

public class ColorPicker extends PopUpButton
{
	public function ColorPicker()
    {
        super();

		var menu:Menu = new Menu();
		menu.items = new ArrayList(new <Object>["p", "noFill"]);
		this.menu = menu;
    }

	public function get argb():uint
	{
		return (0xff << 24) | selectedColor;
	}

	public function get selectedColor():uint
	{
		return 9;
	}
	public function set selectedColor(value:uint):void
	{
	}

    public function set dataProvider(value:Object):void
    {

    }

	override protected function get primaryLaFKey():String
	{
		return "ColorPicker";
	}

	override public function get objectValue():Object
	{
		return 3;
	}

//	override public function commitProperties():void
//	{
//		super.commitProperties();
//
//		if (_menu == null)
//		{
//			var menu:Menu = new Menu();
//			menu.items = new ArrayList(WebSafePalette.getList());
//			this.menu = menu;
//		}
//	}
}
}

class WebSafePalette
{
    public static function getList():Vector.<Object> /* of uint */
    {
        var list:Vector.<Object> = new Vector.<Object>();

		var spacer:uint = 0x000000;
		var c1:Vector.<uint> = new <uint>[0x000000, 0x333333, 0x666666, 0x999999, 0xcccccc, 0xffffff, 0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0x00ffff, 0xff00ff];
		c1.fixed = true;

		var ra:Vector.<String> = new <String>[ "00", "00", "00", "00", "00", "00",
						 "33", "33", "33", "33", "33", "33",
						 "66", "66", "66", "66", "66", "66" ];
		ra.fixed = true;

		var rb:Vector.<String> = new <String>[ "99", "99", "99", "99", "99", "99",
						 "CC", "CC", "CC", "CC", "CC", "CC",
						 "FF", "FF", "FF", "FF", "FF", "FF" ];
		rb.fixed = true;

		var g:Vector.<String> = new <String>[ "00", "33", "66", "99", "CC", "FF",
						"00", "33", "66", "99", "CC", "FF",
						"00", "33", "66", "99", "CC", "FF" ];
		g.fixed = true;

		var b:Vector.<String> = new <String>[ "00", "33", "66", "99", "CC", "FF",
						"00", "33", "66", "99", "CC", "FF" ];
		b.fixed = true;

        for (var x:int = 0; x < 12; x++)
        {
            for (var j:int = 0; j < 20; j++)
            {
                var item:uint;
				if (j == 0)
                {
                    item = c1[x];
                }
                else if (j == 1)
                {
                    item = spacer;
                }
                else
				{
					item = Number("0x" + (x < 6 ? ra[j - 2] : rb[j - 2]) + g[j - 2] + b[x]);
				}

				list[x + j] = item;
            }
        }

        return list;
    }
}