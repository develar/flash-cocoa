package cocoa
{
import mx.core.UIComponent;
import mx.core.mx_internal;

import cocoa.layout.LayoutMetrics;

use namespace mx_internal;

public class LightUIComponent extends UIComponent
{
	public static const LAYOUT_DIRECTION_LTR:String = "ltr";

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

	override public function regenerateStyleCache(recursive:Boolean):void
    {

	}

	override public function styleChanged(styleProp:String):void
    {

	}

	override mx_internal function initThemeColor():Boolean
    {
		return true;
	}

	override public function notifyStyleChangeInChildren(styleProp:String, recursive:Boolean):void
	{

	}

	override public function registerEffects(effects:Array /* of String */):void
    {

	}

	override protected function resourcesChanged():void
    {

	}

	override public function get layoutDirection():String
    {
		return LAYOUT_DIRECTION_LTR;
	}

	override public function setStyle(styleProp:String, newValue:*):void
	{
		super.setStyle(styleProp, newValue);
	}
}
}