package cocoa
{
import spark.components.HSlider;

public class HSlider extends spark.components.HSlider
{
	override protected function nearestValidValue(value:Number, interval:Number):Number
	{
		if (interval == 0)
		{
			return Math.max(minimum, Math.min(maximum, value));
		}

		var minValue:Number = minimum;
		var maxValue:Number = maximum;
		var scale:Number = 1;

		// If interval isn't an integer, there's a possibility that the floating point
		// approximation of value or value/interval will be slightly larger or smaller
		// than the real value.  This can lead to errors in calculations like
		// floor(value/interval)*interval, which one might expect to just equal value,
		// when value is an exact multiple of interval.  Not so if value=0.58 and
		// interval=0.01, in that case the calculation yields 0.57!  To avoid problems,
		// we scale by the implicit precision of the interval and then round.  For
		// example if interval=0.01, then we scale by 100.

		if (interval != int(interval))
		{
			const s:String = String(1 + interval);
			scale = Math.pow(10, s.length - s.indexOf(".") - 1);
			minValue *= scale;
			maxValue *= scale;
			value = Math.round(value * scale);
			interval = Math.round(interval * scale);
		}

		var lower:Number = Math.max(minValue, Math.floor(value / interval) * interval);
		var upper:Number = Math.min(maxValue, Math.floor((value + interval) / interval) * interval);
		return (((value - lower) >= ((upper - lower) / 2)) ? upper : lower) / scale;
	}
}
}