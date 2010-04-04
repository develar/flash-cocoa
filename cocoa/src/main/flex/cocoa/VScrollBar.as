package cocoa
{
import cocoa.plaf.scrollbar.VscrollBarSkin;

import flash.events.MouseEvent;

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

	public final function _trackMouseDownHandler(event:MouseEvent):void
	{
		super.track_mouseDownHandler(event);
	}

	override protected function track_mouseDownHandler(event:MouseEvent):void
	{
		if (event.localY >= Bordered(track).border.contentInsets.top)
		{
			super.track_mouseDownHandler(event);
		}
	}

	override protected function updateSkinDisplayList():void
	{
		if (track == null || thumb == null)
		{
			return;
		}

		var trackSize:Number = track.getLayoutBoundsHeight();
		if (trackSize == 0)
		{
			return;
		}
		var range:Number = maximum - minimum;

		var thumbTopPadding:Number = Bordered(track).border.contentInsets.top;
		trackSize -= thumbTopPadding;

		var thumbPosTrackY:Number = thumbTopPadding;
		var thumbSize:Number = 0;
		if (range > 0)
		{
			thumbSize = Math.max(thumb.minHeight, Math.min((pageSize / (range + pageSize)) * trackSize, trackSize));
			thumbPosTrackY = ((value - minimum) * ((trackSize - thumbSize) / range)) + thumbTopPadding;
		}

		thumb.setLayoutBoundsSize(NaN, thumbSize);
		thumb.setLayoutBoundsPosition(0, Math.round(thumbPosTrackY));
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