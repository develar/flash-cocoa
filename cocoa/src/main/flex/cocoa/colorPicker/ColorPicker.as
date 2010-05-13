package cocoa.colorPicker
{
import flash.display.Graphics;

import mx.controls.ColorPicker;
import mx.core.mx_internal;

use namespace mx_internal;

public class ColorPicker extends mx.controls.ColorPicker
{
	public function get argb():uint
	{
		return (0xff << 24) | selectedColor;
	}

	override protected function measure():void
	{
		measuredMinWidth = measuredWidth = 21;
		measuredMinHeight = measuredHeight = 21;
	}

	protected override function createChildren():void
	{
		super.createChildren();

		setChildIndex(downArrowButton, numChildren - 1);
	}

	protected override function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		downArrowButton.move(0, 0);
		downArrowButton.setActualSize(w, h);

		var downArrowButtonGraphics:Graphics = downArrowButton.graphics;
		downArrowButtonGraphics.clear();
		downArrowButtonGraphics.beginFill(0, 0);
		downArrowButtonGraphics.drawRect(0, 0, w, h);
	}

	override public function drawFocus(isFocused:Boolean):void
	{
		// ignore
	}
}
}