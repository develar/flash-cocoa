package cocoa
{
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

import flash.display.Graphics;

import spark.components.ResizeMode;

public class BorderedContainer extends Container implements ViewContainer, LookAndFeelProvider
{
	public function BorderedContainer()
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

	// GroupBase не вызывает drawBackground, поэтому мы не переопределяем drawBackground как в BorderedDataGroup
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var g:Graphics = graphics;
		g.clear();
		_border.draw(this, g, resizeMode == ResizeMode.SCALE ? measuredWidth : w, resizeMode == ResizeMode.SCALE ? measuredHeight : h);

		super.updateDisplayList(w, h);
	}

	private var _laf:LookAndFeel;
	public function get laf():LookAndFeel
	{
		return _laf;
	}
	public function set laf(value:LookAndFeel):void
	{
		_laf = value;
	}
}
}