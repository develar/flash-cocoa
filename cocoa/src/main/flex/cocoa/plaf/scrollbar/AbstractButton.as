package cocoa.plaf.scrollbar
{
import cocoa.Border;
import cocoa.Bordered;

import flash.display.Graphics;

import mx.core.mx_internal;
import mx.core.UIComponent;

import spark.components.Button;

use namespace mx_internal;

internal class AbstractButton extends Button implements Bordered
{
	protected var _border:Border;
	public function get border():Border
	{
		return _border;
	}

	override public function getStyle(styleProp:String):*
	{
		switch (styleProp)
		{
			case "repeatDelay": return 500;
			case "repeatInterval": return 35;
		}

		return undefined;
	}

	override protected function measure():void
	{
		if (!isNaN(_border.layoutWidth))
		{
			measuredMinWidth = measuredWidth = _border.layoutWidth;
		}
		measuredMinHeight = measuredHeight = _border.layoutHeight;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var g:Graphics = graphics;
		g.clear();
		_border.draw(null, g, w, h);
	}
	
	override protected function attachSkin():void
    {

	}

	override protected function detachSkin():void
    {

	}

	override public function setConstraintValue(constraintName:String, value:*):void
	{
	}

	override public function get skin():UIComponent
	{
		return this;
	}

	override public function invalidateSkinState():void
	{
	}

	// disable unwanted legacy
	include "../../../../unwantedLegacy.as";
}
}