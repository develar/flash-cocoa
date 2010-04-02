package cocoa
{
import cocoa.plaf.scrollbar.VscrollBarSkin;

import mx.core.mx_internal;

import spark.components.VScrollBar;

use namespace mx_internal;

public class VScrollBar extends spark.components.VScrollBar
{
	public function uiPartAdded(id:String, instance:Object):void
	{
		this[id] = instance;
		partAdded(id, instance);
	}

	override public function getStyle(styleProp:String):*
	{
		switch (styleProp)
		{
			case "repeatDelay": return 500;
			case "repeatInterval": return 35;
			case "skinClass": return VscrollBarSkin;
		}

		return undefined;
	}

	// disable unwanted legacy
	override public function regenerateStyleCache(recursive:Boolean):void
	{

	}

	override public function styleChanged(styleProp:String):void
    {

	}

	override protected function resourcesChanged():void
    {

	}

	override public function get layoutDirection():String
    {
		return AbstractView.LAYOUT_DIRECTION_LTR;
	}

	override public function registerEffects(effects:Array /* of String */):void
    {

	}

	override mx_internal function initThemeColor():Boolean
    {
		return true;
	}
}
}