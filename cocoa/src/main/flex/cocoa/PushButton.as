package cocoa
{
public class PushButton extends AbstractButton
{
	override protected function get defaultLaFPrefix():String
	{
		return "PushButton";
	}

	private var _label:String;
	public function get label():String
	{
		return _label;
	}
	public function set label(value:String):void
	{
		if (value != _label)
		{
			_label = value;
			if (mySkin != null)
			{
				mySkin.label = _label;
			}
		}
	}

	override protected function skinAttachedHandler():void
    {
		super.skinAttachedHandler();

		mySkin.label = _label;
	}

	override public function get objectValue():Object
	{
		return label;
	}
}
}