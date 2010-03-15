package cocoa
{
import mx.core.mx_internal;

import spark.components.supportClasses.DropDownListBase;
import spark.utils.LabelUtil;

use namespace mx_internal;

/**
 * http://developer.apple.com/Mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGControls/XHIGControls.html#//apple_ref/doc/uid/TP30000359-TPXREF132
 */
public class PopUpButton extends DropDownListBase
{
	public function PopUpButton()
	{
		super();

		requireSelection = true;
		useVirtualLayout = false; // present up to 12 mutually exclusive choices (according to Apple HIG) – virtual layout is needless
	}

	/**
	 * dropDown and dataGroup must be deferred
	 */
	public function uiPartAdded(id:String, instance:Object):void
	{
		this[id] = instance;
		partAdded(id, instance);
	}

	override mx_internal function updateLabelDisplay(displayItem:* = undefined):void
	{
		if (openButton != null)
		{
			if (displayItem === undefined)
			{
				displayItem = selectedItem;
			}

			PushButton(openButton).label = LabelUtil.itemToLabel(displayItem, labelField, labelFunction);
		}
	}

	override public function get baselinePosition():Number
	{
		return skin.baselinePosition;
	}

	override public function getStyle(styleProp:String):*
    {
		return styleProp == "skinClass" ? UIManager.getUI("PopUpButton") : undefined;
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
		return LightUIComponent.LAYOUT_DIRECTION_LTR;
	}
}
}