package cocoa
{
import cocoa.plaf.basic.scrollbar.VScrollBarSkin;

import flash.events.MouseEvent;

import mx.core.mx_internal;

import spark.components.VScrollBar;

use namespace mx_internal;

public class VScrollBar extends spark.components.VScrollBar implements UIPartController
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
			case "skinClass": return VScrollBarSkin;
		}

		return undefined;
	}

	public final function _trackMouseDownHandler(event:MouseEvent):void
	{
		super.track_mouseDownHandler(event);
	}

	override protected function track_mouseDownHandler(event:MouseEvent):void
	{
		if (event.localY >= FlexButton(track).border.contentInsets.top)
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

		var range:Number = maximum - minimum;
		if (range <= 0)
		{
			skin.invalidateDisplayList();
			return;
		}

		var trackSize:Number = track.getLayoutBoundsHeight();
		if (trackSize == 0)
		{
			return;
		}

		if (!track.visible)
		{
			skin.invalidateDisplayList();
		}

		var thumbTopPadding:Number = FlexButton(track).border.contentInsets.top;
		trackSize -= thumbTopPadding;

		var thumbSize:Number = Math.max(thumb.minHeight, Math.min((pageSize / (range + pageSize)) * trackSize, trackSize));
		thumb.setLayoutBoundsSize(NaN, thumbSize);
		thumb.setLayoutBoundsPosition(0, Math.round(((value - minimum) * ((trackSize - thumbSize) / range)) + thumbTopPadding));
	}

	// disable unwanted legacy
	include "../../unwantedLegacy.as";
}
}