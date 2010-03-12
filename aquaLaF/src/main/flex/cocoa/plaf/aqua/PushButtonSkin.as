package cocoa.plaf.aqua
{
import cocoa.plaf.AbstractPushButtonSkin;
import cocoa.plaf.ButtonState;
import cocoa.plaf.Scale3HBitmapBorder;

import spark.components.Button;

public class PushButtonSkin extends AbstractPushButtonSkin
{
	public function PushButtonSkin()
	{
		// as compiler sucks — can not init const in declaration
		_currentState = ButtonState.up;

		super();
	}

	private var _currentState:ButtonState;
	override public function get currentState():String
    {
        return _currentState.name;
    }
    override public function set currentState(value:String):void
    {
        if (value != _currentState.name)
		{
			if (value != ButtonState.over.name)
			{
				_currentState = ButtonState.valueOf(value);
			}
			else if (_currentState == ButtonState.up)
			{
				return;
			}
			else // down
			{
				_currentState = ButtonState.up;
			}

			invalidateDisplayList();
		}
    }

	override public function regenerateStyleCache(recursive:Boolean):void
    {
		var bezel:String = Button(parent).getStyle("bezel");
		border = getBorder("border." + (bezel == null ? BezelStyle.rounded.name : bezel));
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		Scale3HBitmapBorder(border).bitmapIndex = _currentState.ordinal << 1;
		labelHelper.font = getFont(_currentState == ButtonState.disabled ? "SystemFont.disabled" : "SystemFont");

		super.updateDisplayList(w, h);
	}
}
}