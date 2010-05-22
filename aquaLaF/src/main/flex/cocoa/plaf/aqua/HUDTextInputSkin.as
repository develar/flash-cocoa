package cocoa.plaf.aqua
{
import cocoa.Border;
import cocoa.RichEditableText;
import cocoa.plaf.AbstractSkin;

import flash.display.Graphics;
import flash.text.engine.ElementFormat;

import flashx.textLayout.formats.LineBreak;

public class HUDTextInputSkin extends AbstractSkin
{
	protected var textDisplay:RichEditableText;

	private var border:Border;

	protected function setAdditionalTextStyle():void
	{
		textDisplay.setStyle("paddingTop", 2);
		textDisplay.setStyle("focusedTextSelectionColor", 0xb5b5b5);
	}

	override protected function createChildren():void
	{
		super.createChildren();

		border = getBorder("border");
		var font:ElementFormat = getFont("SystemFont");

		textDisplay = new RichEditableText();
		textDisplay.font = font;
		
		textDisplay.setStyle("lineBreak", LineBreak.EXPLICIT);
		setAdditionalTextStyle();

		textDisplay.multiline = false;
		textDisplay.heightInLines = 1;
		textDisplay.x = border.contentInsets.left;
		textDisplay.y = border.contentInsets.top;
		textDisplay.height = border.layoutHeight - border.contentInsets.height;

		addChild(textDisplay);

		component.uiPartAdded("textDisplay", textDisplay);
	}

	override protected function measure():void
	{
		measuredWidth = textDisplay.getPreferredBoundsWidth() + border.contentInsets.width;
		measuredHeight = border.layoutHeight;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var g:Graphics = graphics;
		g.clear();

		border.draw(this, g, w, h);

		textDisplay.setLayoutBoundsSize(w - border.contentInsets.width, NaN);
	}
}
}