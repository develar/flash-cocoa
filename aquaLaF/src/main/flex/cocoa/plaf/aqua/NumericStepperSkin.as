package cocoa.plaf.aqua
{
import cocoa.FlexButton;
import cocoa.LightFlexUIComponent;
import cocoa.TextInput;
import cocoa.UIPartController;
import cocoa.UIPartProvider;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.ui;

import flash.display.DisplayObject;

use namespace ui;

public class NumericStepperSkin extends LightFlexUIComponent implements UIPartProvider
{
	protected var textDisplay:TextInput;

	protected var incrementButton:FlexButton;
	protected var decrementButton:FlexButton;

	private static const PADDING_BETWEEN_TEXT_AND_SPINNER:int = 7;

	override protected function createChildren():void
	{
		var laf:LookAndFeel = LookAndFeelProvider(parent.parent).laf;
		textDisplay = new TextInput();
		textDisplay.lafPrefix = "NumericStepper.TextInput";
		var textInputSkin:DisplayObject = DisplayObject(textDisplay.createView(laf));
		addChild(textInputSkin);

		UIPartController(parent).uiPartAdded("textDisplay", textDisplay);

		incrementButton = createSpinnerButton("incrementButton", laf);
		decrementButton = createSpinnerButton("decrementButton", laf);

		decrementButton.y = incrementButton.border.layoutHeight;
	}

	protected function createSpinnerButton(id:String, laf:LookAndFeel):FlexButton
	{
		var button:FlexButton = new FlexButton();
		button.border = laf.getBorder("NumericStepper." + id);
		addChild(button);
		UIPartController(parent).uiPartAdded(id, button);
		return button;
	}

	override protected function measure():void
	{
		measuredWidth = textDisplay.skin.getPreferredBoundsWidth() + PADDING_BETWEEN_TEXT_AND_SPINNER + incrementButton.getExplicitOrMeasuredWidth();
		measuredHeight = textDisplay.skin.getPreferredBoundsHeight();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		const spinnerWidth:Number = incrementButton.getExplicitOrMeasuredWidth();
		textDisplay.skin.setActualSize(w - PADDING_BETWEEN_TEXT_AND_SPINNER - spinnerWidth, h);

		incrementButton.setLayoutBoundsSize(spinnerWidth, NaN);
		decrementButton.setLayoutBoundsSize(spinnerWidth, NaN);

		incrementButton.x = w - spinnerWidth;
		decrementButton.x = w - spinnerWidth;
	}

	override public function set enabled(value:Boolean):void
	{
		if (enabled != value)
		{
			super.enabled = value;
			alpha = enabled ? 1 : 0.5;
		}
	}
}
}