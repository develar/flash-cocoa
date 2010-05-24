package cocoa.plaf.aqua
{
import cocoa.AbstractFlexButton;
import cocoa.LightFlexUIComponent;
import cocoa.TextInput;
import cocoa.UIPartController;
import cocoa.UIPartProvider;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.ui;

import flash.display.DisplayObject;

import flashx.textLayout.formats.TextAlign;

use namespace ui;

public class NumericStepperSkin extends LightFlexUIComponent implements UIPartProvider
{
	private var textDisplay:TextInput;

	private var incrementButton:AbstractFlexButton;
	private var decrementButton:AbstractFlexButton;

	private static const PADDING_BETWEEN_TEXT_AND_SPINNER:int = 7;

	override protected function createChildren():void
	{
		super.createChildren();

		var laf:LookAndFeel = LookAndFeelProvider(parent.parent).laf;
		textDisplay = new TextInput();
		textDisplay.lafPrefix = "NumericStepper.TextInput";
		var textInputSkin:DisplayObject = DisplayObject(textDisplay.createView(laf));
		addChild(textInputSkin);

		textDisplay.textDisplay.setStyle("textAlign", TextAlign.END);

		UIPartController(parent).uiPartAdded("textDisplay", textDisplay);

		incrementButton = createSpinnerButton("incrementButton", laf);
		decrementButton = createSpinnerButton("decrementButton", laf);

		decrementButton.y = incrementButton.border.layoutHeight;
	}

	private function createSpinnerButton(id:String, laf:LookAndFeel):AbstractFlexButton
	{
		var button:AbstractFlexButton = new AbstractFlexButton();
		button.border = laf.getBorder("NumericStepper." + id + ".border");
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
}
}