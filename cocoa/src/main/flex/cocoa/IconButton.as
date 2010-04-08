package cocoa
{
public class IconButton extends PushButton
{
	override public function get lafPrefix():String
	{
		return "IconButton";
	}

	private var _icon:Icon;
	public function get icon():Icon
	{
		return _icon;
	}
	public function set icon(value:Icon):void
	{
		if (value != _icon)
		{
			_icon = value;
			if (mySkin != null)
			{
//				mySkin.icon = _icon;
			}
		}
	}

	override protected function skinAttachedHandler():void
    {
		super.skinAttachedHandler();

//		mySkin.icon = _icon;
	}
}
}