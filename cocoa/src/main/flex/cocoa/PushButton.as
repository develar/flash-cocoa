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
	
	protected var _toolTip:String;
	public function set toolTip(value:String):void
	{
		if (value != _toolTip)
		{
			_toolTip = value;
			if (mySkin != null)
			{
				mySkin.toolTip = _toolTip;
			}
		}
	}

	override protected function skinAttachedHandler():void
    {
		super.skinAttachedHandler();

		mySkin.label = _label;
		if (_toolTip != null)
		{
			mySkin.toolTip = _toolTip;
		}
	}

	override public function get objectValue():Object
	{
		return label;
	}
}
}