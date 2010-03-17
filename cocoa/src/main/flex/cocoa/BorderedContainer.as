package cocoa
{
import flash.display.Graphics;

import mx.core.mx_internal;

import spark.components.ResizeMode;

use namespace mx_internal;

public class BorderedContainer extends Container
{
	private var _border:Border;
	public function get border():Border
	{
		return _border;
	}
	public function set border(value:Border):void
	{
		_border = value;
	}

	override mx_internal function drawBackground():void
	{
		var g:Graphics = graphics;
		g.clear();
		_border.draw(this, g, resizeMode == ResizeMode.SCALE ? measuredWidth : unscaledWidth, resizeMode == ResizeMode.SCALE ? measuredHeight : unscaledHeight);
	}
}
}