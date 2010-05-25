package cocoa
{
import cocoa.plaf.scrollbar.HScrollBarSkin;

import flash.events.MouseEvent;

import mx.core.mx_internal;

import spark.components.HScrollBar;

use namespace mx_internal;

public class HScrollBar extends spark.components.HScrollBar implements UIPartController
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
			case "skinClass": return HScrollBarSkin;
		}

		return undefined;
	}

	public final function _trackMouseDownHandler(event:MouseEvent):void
	{
		super.track_mouseDownHandler(event);
	}

	override protected function track_mouseDownHandler(event:MouseEvent):void
	{
		if (event.localX >= FlexButton(track).border.contentInsets.left)
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
		
		var trackSize:Number = track.getLayoutBoundsWidth();
		if (trackSize == 0)
		{
			return;
		}

		if (!track.visible)
		{
			skin.invalidateDisplayList();
		}

		var thumbleftPadding:Number = FlexButton(track).border.contentInsets.left;
		trackSize -= thumbleftPadding;

		var thumbSize:Number = Math.max(thumb.minWidth, Math.min((pageSize / (range + pageSize)) * trackSize, trackSize));
		thumb.setLayoutBoundsSize(thumbSize, NaN);
		thumb.setLayoutBoundsPosition(Math.round(((value - minimum) * ((trackSize - thumbSize) / range)) + thumbleftPadding), 0);
	}

	// disable unwanted legacy
	include "../../unwantedLegacy.as";
}
}