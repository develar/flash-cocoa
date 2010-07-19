package cocoa.plaf.aqua
{
import flash.display.Graphics;

public class TextAreaSkin extends TextInputSkin
{
	public function TextAreaSkin()
	{
	}

	override protected function configureTextDisplay():void
	{
		// skip
	}

	override protected function measure():void
	{
		measuredWidth = textDisplay.getPreferredBoundsWidth() + border.contentInsets.width;
		measuredHeight = Math.ceil(textDisplay.getPreferredBoundsHeight()) + border.contentInsets.height;
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