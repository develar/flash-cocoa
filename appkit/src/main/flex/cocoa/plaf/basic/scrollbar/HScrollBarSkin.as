package cocoa.plaf.basic.scrollbar
{
import spark.components.supportClasses.ScrollBarBase;

public class HScrollBarSkin extends AbstractScrollBarSkin
{
	override protected function get orientation():String
	{
		return "h";
	}
	
	override protected function measure():void
	{
		measuredMinWidth = measuredWidth = thumb.getExplicitOrMeasuredWidth() + decrementButton.getExplicitOrMeasuredWidth() + incrementButton.getExplicitOrMeasuredWidth();
		measuredMinHeight = measuredHeight = track.getExplicitOrMeasuredHeight();
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
			var incrementButtonWidth:Number = incrementButton.getPreferredBoundsWidth();
			var decrementButtonX:Number = w - decrementButton.getPreferredBoundsWidth() - incrementButtonWidth;

			track.setLayoutBoundsSize(decrementButtonX, NaN);

			decrementButton.setLayoutBoundsSize(NaN, NaN);
			incrementButton.setLayoutBoundsSize(NaN, NaN);

			decrementButton.setLayoutBoundsPosition(decrementButtonX, 0);
			incrementButton.setLayoutBoundsPosition(w - incrementButtonWidth, 0);
		}
	}
}
}