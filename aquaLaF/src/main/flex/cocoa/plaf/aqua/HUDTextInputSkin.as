package cocoa.plaf.aqua
{
import cocoa.Border;

import cocoa.plaf.LookAndFeelProvider;

import flash.display.Graphics;

import flashx.textLayout.formats.VerticalAlign;

import mx.core.UIComponent;

import spark.components.RichEditableText;

public class HUDTextInputSkin extends UIComponent
{
	public var textDisplay:RichEditableText;

	private var border:Border;

	override public function set currentState(value:String):void
    {
		// skip
	}

	override protected function createChildren():void
	{
		super.createChildren();

		textDisplay = new RichEditableText();
		textDisplay.setStyle("color", 0x1e395b);
		textDisplay.setStyle("fontFamily", "SegoeUI");
		textDisplay.setStyle("fontLookup", "embeddedCFF");
		textDisplay.setStyle("verticalAlign", VerticalAlign.MIDDLE);

		textDisplay.multiline = false;
		textDisplay.x = 1;
		textDisplay.y = 1;
		addChild(textDisplay);

		border = LookAndFeelProvider(parent).laf.getBorder("border");
	}

	override protected function measure():void
	{
		measuredWidth = textDisplay.getPreferredBoundsWidth() + border.contentInsets.width;
		measuredHeight = textDisplay.getPreferredBoundsHeight() + border.contentInsets.height;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		var g:Graphics = graphics;
		g.clear();

		border.draw(null, g, w, h);

		textDisplay.setLayoutBoundsSize(w - 2, h - 1);
	}
}
}