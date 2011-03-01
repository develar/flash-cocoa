package cocoa
{
import flash.display.Graphics;

import mx.core.mx_internal;

import spark.components.ResizeMode;
import spark.layouts.VerticalLayout;

use namespace mx_internal;

public class BorderedDataGroup extends FlexDataGroup implements View
{
	public function BorderedDataGroup()
	{
		super();

		mouseEnabledWhereTransparent = false; // border is responsible for
	}

	private var _border:Border;
	public function get border():Border
	{
		return _border;
	}
	public function set border(value:Border):void
	{
		_border = value;
	}

	override protected function measure():void
	{
		var contentInsets:Insets = _border.contentInsets;

		if (layout is VerticalLayout)
		{
			var verticalLayout:VerticalLayout = VerticalLayout(layout);
			verticalLayout.paddingLeft = contentInsets.left;
			verticalLayout.paddingTop = contentInsets.top;
			verticalLayout.paddingRight = contentInsets.right;
			verticalLayout.paddingBottom = contentInsets.bottom;
		}
		
		super.measure();

		measuredWidth += contentInsets.width;
		measuredWidth += contentInsets.height;
	}

	override mx_internal function drawBackground():void
	{
		var g:Graphics = graphics;
		g.clear();
		_border.draw(this, g, resizeMode == ResizeMode.SCALE ? measuredWidth : unscaledWidth, resizeMode == ResizeMode.SCALE ? measuredHeight : unscaledHeight);
	}
}
}