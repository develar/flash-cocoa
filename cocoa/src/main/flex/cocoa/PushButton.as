package cocoa
{
import cocoa.plaf.PushButtonSkin;

import spark.components.Button;

[Style(name="bezel", type="String", enumeration="rounded,texturedRounded")]
public class PushButton extends Button
{
	private var _label:String;
	override public function get label():String
	{
		return _label;
	}
	override public function set label(value:String):void
	{
		if (value != _label)
		{
			_label = value;
			if (skin != null)
			{
				PushButtonSkin(skin).label = _label;
			}
		}
	}

	override protected function attachSkin():void
    {
		super.attachSkin();

		PushButtonSkin(skin).label = _label;
	}

	override public function get baselinePosition():Number
	{
		return skin.baselinePosition;
	}
}
}