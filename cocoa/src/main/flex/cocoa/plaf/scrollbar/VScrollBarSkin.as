package cocoa.plaf.scrollbar
{
import spark.components.supportClasses.ScrollBarBase;

public class VScrollBarSkin extends AbstractScrollBarSkin
{
	override protected function get orientation():String
	{
		return "v";
	}

	override protected function measure():void
	{
		measuredMinWidth = measuredWidth = track.getExplicitOrMeasuredWidth();
		measuredMinHeight = measuredHeight = thumb.getExplicitOrMeasuredHeight() + decrementButton.getExplicitOrMeasuredHeight() + incrementButton.getExplicitOrMeasuredHeight();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var isOff:Boolean = ScrollBarBase(parent).maximum <= ScrollBarBase(parent).minimum;

		if (isOff == track.visible)
		{
			graphics.clear();
			track.visible = !isOff;
			thumb.visible = !isOff;
			decrementButton.visible = !isOff;
			incrementButton.visible = !isOff;
		}

		if (isOff)
		{
			offBorder.draw(null, graphics, w, h);
		}
		else
		{
			var incrementButtonHeight:Number = incrementButton.getPreferredBoundsHeight();
			var decrementButtonY:Number = h - decrementButton.getPreferredBoundsHeight() - incrementButtonHeight;

			track.setLayoutBoundsSize(NaN, decrementButtonY);

			decrementButton.setLayoutBoundsSize(NaN, NaN);
			incrementButton.setLayoutBoundsSize(NaN, NaN);

			decrementButton.setLayoutBoundsPosition(0, decrementButtonY);
			incrementButton.setLayoutBoundsPosition(0, h - incrementButtonHeight);
		}
	}
}
}