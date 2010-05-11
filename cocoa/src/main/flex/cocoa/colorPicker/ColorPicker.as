package cocoa.colorPicker
{
import mx.controls.ColorPicker;

public class ColorPicker extends mx.controls.ColorPicker
{
	public function get argb():uint
	{
		return (0xff << 24) | selectedColor;
	}

	override protected function measure():void
	{
		measuredMinWidth = measuredWidth = 21;
		measuredMinHeight = measuredHeight = 21;
	}
}
}