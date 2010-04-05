package cocoa
{
import mx.core.UIComponent;
import mx.core.mx_internal;

import cocoa.layout.LayoutMetrics;

use namespace mx_internal;

public class LightFlexUIComponent extends UIComponent
{
	private var layoutMetrics:LayoutMetrics;

	include "../../unwantedLegacy.as";

	override public function getConstraintValue(constraintName:String):*
    {
		if (layoutMetrics == null)
		{
			return undefined;
		}
		else
		{
			var value:Number = layoutMetrics[constraintName];
			return isNaN(value) ? undefined : value;
		}
	}

	override public function set currentState(value:String):void
    {
    }

	override public function setConstraintValue(constraintName:String, value:*):void
    {
		if (layoutMetrics == null)
		{
			layoutMetrics = new LayoutMetrics();
		}

		layoutMetrics[constraintName] = value;
	}

//	override public function getStyle(styleProp:String):*
//	{
//		return super.getStyle(styleProp);
//	}
}
}
