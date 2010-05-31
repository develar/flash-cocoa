package cocoa
{
import cocoa.plaf.IconButtonSkin;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

public class ToggleIconButton extends IconButton implements ToggleButton
{
	override protected function get toggled():Boolean
	{
		return true;
	}

	private var _alternateIconId:String;
	public function set alternateIconId(value:String):void
	{
		if (value != _alternateIconId)
		{
			_alternateIconId = value;
		}
	}

	private var _alternateIcon:Icon;
	public function get alternateIcon():Icon
	{
		return _alternateIcon;
	}
	public function set alternateIcon(value:Icon):void
	{
		if (value != _alternateIcon)
		{
			_alternateIcon = value;
			if (mySkin != null && state == CellState.ON)
			{
				IconButtonSkin(mySkin).icon = _alternateIcon;
			}
		}
	}

	override public function createView(laf:LookAndFeel):Skin
	{
		if (_alternateIconId != null)
		{
			_alternateIcon = laf.getIcon(_alternateIconId);
		}

		return super.createView(laf);
	}

	override protected function skinAttachedHandler():void
	{
		super.skinAttachedHandler();
	}

	override public function set state(value:int):void
	{
		if (_alternateIcon != null)
		{
			IconButtonSkin(mySkin).icon = value == CellState.ON ? _alternateIcon : icon;
		}

		super.state = value;
	}
}
}