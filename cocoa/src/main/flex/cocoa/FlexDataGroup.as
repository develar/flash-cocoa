package cocoa
{
import cocoa.layout.LayoutMetrics;

import flash.display.DisplayObjectContainer;

import mx.core.mx_internal;

import spark.components.DataGroup;

use namespace mx_internal;

public class FlexDataGroup extends DataGroup
{
	// disable unwanted legacy

	private var layoutMetrics:LayoutMetrics;

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

	override public function setConstraintValue(constraintName:String, value:*):void
    {
		if (layoutMetrics == null)
		{
			layoutMetrics = new LayoutMetrics();
		}

		layoutMetrics[constraintName] = value;
	}

	include "../../unwantedLegacy.as";

	override public function parentChanged(p:DisplayObjectContainer):void
	{
		super.parentChanged(p);

		if (p != null)
		{
			_parent = p; // так как наше AbstractView не есть ни IStyleClient, ни ISystemManager
		}
	}
}
}