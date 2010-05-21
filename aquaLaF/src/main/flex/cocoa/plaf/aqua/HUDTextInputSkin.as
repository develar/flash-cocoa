package cocoa.plaf.aqua
{
import cocoa.Border;
import cocoa.RichEditableText;
import cocoa.plaf.AbstractSkin;

import flash.display.Graphics;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontLookup;

import flashx.textLayout.formats.LineBreak;

public class HUDTextInputSkin extends AbstractSkin
{
	private var textDisplay:RichEditableText;

	private var border:Border;

	override protected function createChildren():void
	{
		super.createChildren();

		border = getBorder("border");
		height = border.layoutHeight;
		var font:ElementFormat = getFont("SystemFont");

		textDisplay = new RichEditableText();
		textDisplay.setStyle("color", font.color);
		textDisplay.setStyle("fontFamily", font.fontDescription.fontName);
		textDisplay.setStyle("fontSize", font.fontSize);
		textDisplay.setStyle("fontLookup", FontLookup.DEVICE);
		
		textDisplay.setStyle("lineBreak", LineBreak.EXPLICIT);
		textDisplay.setStyle("paddingTop", 2);

		textDisplay.setStyle("focusedTextSelectionColor", 0xb5b5b5);

		textDisplay.multiline = false;
		textDisplay.heightInLines = 1;
		textDisplay.x = border.contentInsets.left;
		textDisplay.y = border.contentInsets.top;
		textDisplay.maxHeight = textDisplay.height = border.layoutHeight - border.contentInsets.height;

		addChild(textDisplay);

		component.uiPartAdded("textDisplay", textDisplay);
	}

	override protected function measure():void
	{
		measuredWidth = textDisplay.getPreferredBoundsWidth() + border.contentInsets.width;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var g:Graphics = graphics;
		g.clear();

		border.draw(null, g, w, h);

		textDisplay.setLayoutBoundsSize(w - border.contentInsets.width, NaN);
	}
}
}