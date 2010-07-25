package cocoa
{
use namespace ui;

public class TextArea extends TextInput
{
	private var _heightInLines:Number;
	override protected function get primaryLaFKey():String
	{
		return "TextArea";
	}

	public function set heightInLines(value:Number):void
	{
		_heightInLines = value;
		if (textDisplay != null && _heightInLines != value)
		{
			textDisplay.heightInLines = value;
		}
	}

	override ui function textDisplayAdded():void
	{
		super.textDisplayAdded();

		textDisplay.heightInLines = _heightInLines;
	}
}
}