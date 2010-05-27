package cocoa.plaf.aqua
{
import cocoa.Border;
import cocoa.plaf.AbstractSkin;
import cocoa.text.EditableTextView;

import flash.display.Graphics;

public class TextInputSkin extends AbstractSkin
{
	protected var textDisplay:EditableTextView;

	private var border:Border;

	override protected function createChildren():void
	{
		super.createChildren();

		border = getBorder("border");

		textDisplay = new EditableTextView();
		textDisplay.textFormat = getTextFormat("SystemTextFormat");
		textDisplay.selectionFormat = laf.getSelectionFormat("SelectionFormat");

		textDisplay.multiline = false;
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