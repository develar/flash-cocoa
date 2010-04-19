package cocoa.plaf.basic
{
import cocoa.Border;
import cocoa.FlexDataGroup;
import cocoa.LightFlexUIComponent;
import cocoa.ScrollView;
import cocoa.plaf.ListViewSkin;
import cocoa.plaf.LookAndFeel;

import flash.display.Graphics;

public class ListViewSkin extends LightFlexUIComponent implements cocoa.plaf.ListViewSkin
{
	public var scrollView:ScrollView;
	public var dataGroup:FlexDataGroup;

	private var border:Border;

	private var _laf:LookAndFeel;
	public function set laf(value:LookAndFeel):void
	{
		_laf = value;

		border = _laf.getBorder("ListView.border");

		dataGroup = new FlexDataGroup();

		scrollView = new ScrollView();
		scrollView.hasFocusableChildren = false;
		scrollView.documentView = dataGroup;

		scrollView.move(border.contentInsets.left, border.contentInsets.top);

		addChild(scrollView);
	}

	public function set verticalScrollbarPolicy(value:uint):void
	{
		scrollView.verticalScrollbarPolicy = value;
	}

	public function set horizontalScrollbarPolicy(value:uint):void
	{
		scrollView.horizontalScrollbarPolicy = value;
	}

	override protected function measure():void
	{
		measuredMinWidth = scrollView.getMinBoundsWidth() + border.contentInsets.width;
        measuredWidth = scrollView.getPreferredBoundsWidth() + border.contentInsets.width;

        measuredMinHeight = scrollView.getMinBoundsHeight() + border.contentInsets.height;
        measuredHeight = scrollView.getPreferredBoundsHeight() + border.contentInsets.height;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		scrollView.setActualSize(w - border.contentInsets.width, h - border.contentInsets.height);

		var g:Graphics = graphics;
		g.clear();
		border.draw(null, g, w, h);
	}
}
}