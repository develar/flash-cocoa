package cocoa.colorPicker
{
import cocoa.AbstractControl;
import cocoa.Cell;

import mx.core.mx_internal;

use namespace mx_internal;

public class ColorPicker extends AbstractControl implements Cell
{
	public function ColorPicker()
    {
        super();
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
}
}