package cocoa.plaf.aqua
{
import cocoa.Border;
import cocoa.plaf.basic.AbstractSkin;
import cocoa.text.EditableTextView;

import flash.display.Graphics;

/**
 * http://developer.apple.com/mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGControls/XHIGControls.html#//apple_ref/doc/uid/TP30000359-TPXREF225
 */
public class TextInputSkin extends AbstractSkin
{
	protected var textDisplay:EditableTextView;

	protected var border:Border;

	override protected function createChildren():void
	{
		super.createChildren();

		border = getBorder("border");

		textDisplay = new EditableTextView();
		if (!enabled)
		{
			textDisplay.enabled = false;
		}
		textDisplay.textFormat = getTextLayoutFormat("SystemTextFormat");
		textDisplay.selectionFormat = laf.getSelectionFormat("SelectionFormat");

		textDisplay.x = border.contentInsets.left;
		textDisplay.y = border.contentInsets.top;
		configureTextDisplay();

		addChild(textDisplay);

		component.uiPartAdded("textDisplay", textDisplay);
	}

	protected function configureTextDisplay():void
	{
		textDisplay.multiline = false;
		textDisplay.height = border.layoutHeight - border.contentInsets.height;
	}

	override protected function measure():void
	{
		measuredWidth = textDisplay.getPreferredBoundsWidth() + border.contentInsets.width;
		measuredHeight = isNaN(border.layoutHeight) ? 22 /* Regular size: 22 pixels high*/ : border.layoutHeight;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var g:Graphics = graphics;
		g.clear();

		border.draw(this, g, w, h);

		textDisplay.setLayoutBoundsSize(w - border.contentInsets.width, NaN);
	}

	override public function set enabled(value:Boolean):void
	{
		if (value != enabled)
		{
			super.enabled = value;
			if (textDisplay != null)
			{
				textDisplay.enabled = value;
			}
		}
	}
}
}