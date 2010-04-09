package cocoa
{
import cocoa.plaf.IconButtonSkin;

public class IconButton extends PushButton
{
	override protected function get defaultLaFPrefix():String
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
				IconButtonSkin(mySkin).icon = _icon;
			}
		}
	}

	override protected function skinAttachedHandler():void
    {
		super.skinAttachedHandler();

		IconButtonSkin(mySkin).icon = _icon;
	}
}
}