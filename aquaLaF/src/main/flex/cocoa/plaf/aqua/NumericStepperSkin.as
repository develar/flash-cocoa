package cocoa.plaf.aqua
{
import cocoa.LightFlexUIComponent;
import cocoa.TextInput;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

import flash.display.DisplayObject;

public class NumericStepperSkin extends LightFlexUIComponent
{
	public var textDisplay:TextInput;

	public function NumericStepperSkin()
	{
	}

	override protected function createChildren():void
	{
		super.createChildren();

		var laf:LookAndFeel = LookAndFeelProvider(parent.parent).laf;
		textDisplay = new TextInput();
		var textInputSkin:DisplayObject = DisplayObject(textDisplay.createView(laf));
		addChild(textInputSkin);
	}

	override protected function measure():void
	{
		measuredWidth = textDisplay.skin.getPreferredBoundsWidth();
		measuredHeight = textDisplay.skin.getPreferredBoundsHeight();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		textDisplay.skin.setActualSize(w, h);
	}
}
}