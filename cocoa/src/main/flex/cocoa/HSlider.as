package cocoa
{
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.HSlider;

use namespace mx_internal;

public class HSlider extends spark.components.HSlider implements UIPartController
{
	override public function set enabled(value:Boolean):void
	{
		super.enabled = value;
		if (skin != null)
		{
			skin.enabled = value;
		}
	}
	
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

	// disable unwanted legacy
	include "../../unwantedLegacy.as";
	include "../../legacyConstraints.as";

	private var mySkin:UIComponent;
	override public function get skin():UIComponent
	{
		return mySkin;
	}

	private var skinClass:Class;
	override protected function createChildren():void
	{
		var laf:LookAndFeel = LookAndFeelProvider(parent).laf;
		skinClass = laf.getClass("HSlider");

		mySkin = new skinClass();
		if (mySkin is LookAndFeelProvider)
		{
			LookAndFeelProvider(mySkin).$laf = laf;
		}

		addingChild(mySkin);
		$addChildAt(mySkin, 0);
		childAdded(mySkin);

		if (!(mySkin is UIPartProvider))
		{
			findSkinParts();
			invalidateSkinState();
		}
	}

	override protected function attachSkin():void
	{

	}

	override public function getStyle(styleProp:String):*
	{
		if (styleProp == "skinClass")
		{
			return skinClass;
		}
		else if (styleProp == "liveDragging")
		{
			return true;
		}
		else if (styleProp == "layoutDirection")
		{
			return layoutDirection;
		}
		else if (styleProp == "slideDuration")
		{
			return 0;
		}
		else
		{
			throw new Error("unknown " + styleProp);
		}
	}

	public function uiPartAdded(id:String, instance:Object):void
	{
		this[id] = instance;
		partAdded(id, instance);
	}

	/**
	 * http://juick.com/develar/751830
	 */
	override public function get snapInterval():Number
	{
		return stepSize;
	}

	override public function set snapInterval(value:Number):void
	{
		assert(false, "http://juick.com/develar/751830");
	}
}
}