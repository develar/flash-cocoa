package cocoa
{
public class PushButton extends AbstractButton
{
	override public function get stylePrefix():String
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

	override protected function viewAttachedHandler():void
    {
		super.viewAttachedHandler();

		mySkin.label = _label;
	}
}
}