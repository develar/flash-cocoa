package cocoa
{
import cocoa.plaf.IconButtonSkin;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

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

	private var _iconId:String;
	public function set iconId(value:String):void
	{
		if (value != _iconId)
		{
			_iconId = value;
		}
	}

	override protected function skinAttachedHandler():void
    {
		super.skinAttachedHandler();

		IconButtonSkin(mySkin).icon = _icon;
	}

	override public function createView(laf:LookAndFeel):Skin
	{
		if (_iconId != null)
		{
			_icon = laf.getIcon(_iconId);
		}
		
		return super.createView(laf);
	}
}
}