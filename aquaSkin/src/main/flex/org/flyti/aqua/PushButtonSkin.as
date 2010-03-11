package org.flyti.aqua
{
import flash.display.Graphics;

import org.flyti.view.ButtonState;

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
		border = AquaBorderFactory.getPushButtonBorder(bezel == null ? BezelStyle.rounded : BezelStyle.valueOf(bezel));
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		labelHelper.font = _currentState == ButtonState.disabled ? AquaFonts.SYSTEM_FONT_DISABLED : AquaFonts.SYSTEM_FONT;
		labelHelper.validate();

		labelHelper.moveByInsets(h, border.textInsets, border.layoutInsets);

		var g:Graphics = graphics;
		g.clear();
		border.draw(this, g, w, h, _currentState);
	}
}
}