package cocoa
{
public class PushButton extends AbstractButton
{
	override protected function get primaryLaFKey():String
	{
		return "PushButton";
	}
	
	protected var _toolTip:String;
	public function set toolTip(value:String):void
	{
		if (value != _toolTip)
		{
			_toolTip = value;
			if (skin != null)
			{
				skin.toolTip = _toolTip;
			}
		}
	}

	private var _alternateToolTip:String;
	public function set alternateToolTip(value:String):void
	{
		if (value != _alternateToolTip)
		{
			_alternateToolTip = value;
			if (skin != null && state == CellState.ON)
			{
				skin.toolTip = _alternateToolTip;
			}
		}
	}

	override protected function skinAttachedHandler():void
    {
		super.skinAttachedHandler();

		if (_toolTip != null)
		{
			skin.toolTip = _toolTip;
		}
	}

	override public function set state(value:int):void
	{
		if (_alternateToolTip != null)
		{
			skin.toolTip = value == CellState.ON ? _alternateToolTip : _toolTip;
		}

		super.state = value;
	}
}
}