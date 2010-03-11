package org.flyti.aqua
{
import mx.core.mx_internal;

import org.flyti.view.LightUIComponent;
import org.flyti.view.PushButtonSkin;

import spark.components.ButtonBarButton;

use namespace mx_internal;

public class AquaBarButton extends ButtonBarButton
{
	public function AquaBarButton()
	{
		super();

		mouseChildren = true;
	}
	
	override public function getStyle(styleProp:String):*
    {
		if (styleProp == "skinClass")
		{
			return TabLabelSkin;
		}
		else
		{
			return undefined;
		}
	}

	override protected function addHandlers():void
	{
		// Кнопка в панели не отвечает за MOUSE_DOWN и MOUSE_UP — выделение осуществляет менеджер, а over state для Aqua не нужен
	}

	override public function set label(value:String):void
	{
		org.flyti.view.PushButtonSkin(skin).label = value;
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