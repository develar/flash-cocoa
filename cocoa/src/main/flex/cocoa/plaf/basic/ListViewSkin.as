package cocoa.plaf.basic
{
import cocoa.Border;
import cocoa.FlexDataGroup;
import cocoa.LightFlexUIComponent;
import cocoa.ListView;
import cocoa.ScrollPolicy;
import cocoa.ScrollView;
import cocoa.plaf.ListViewSkin;
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObject;
import flash.display.Graphics;

import mx.core.IUIComponent;

public class ListViewSkin extends LightFlexUIComponent implements cocoa.plaf.ListViewSkin
{
	private var scrollView:ScrollView;
	protected var dataGroup:FlexDataGroup;
	private var contentView:IUIComponent;

	private var border:Border;

	protected var _laf:LookAndFeel;
	public function set laf(value:LookAndFeel):void
	{
		_laf = value;
	}

	override protected function createChildren():void
	{
		border = _laf.getBorder("ListView.border");

		dataGroup = new FlexDataGroup();

		if (_horizontalScrollPolicy != ScrollPolicy.OFF && _verticalScrollPolicy != ScrollPolicy.OFF)
		{
			scrollView = new ScrollView();
			scrollView.hasFocusableChildren = false;
			scrollView.documentView = dataGroup;

			scrollView.horizontalScrollPolicy = _horizontalScrollPolicy;
			scrollView.verticalScrollPolicy = _verticalScrollPolicy;

			contentView = scrollView;
		}
		else
		{
			contentView = dataGroup;
		}

		contentView.move(border.contentInsets.left, border.contentInsets.top);
		addChild(DisplayObject(contentView));

		ListView(parent).uiPartAdded("dataGroup", dataGroup);
	}

	private var _verticalScrollPolicy:int;
	public function set verticalScrollPolicy(value:uint):void
	{
		_verticalScrollPolicy = value;
		if (scrollView != null)
		{
			scrollView.verticalScrollPolicy = value;
		}
	}

	private var _horizontalScrollPolicy:int;
	public function set horizontalScrollPolicy(value:uint):void
	{
		_horizontalScrollPolicy = value;
		if (scrollView != null)
		{
			scrollView.horizontalScrollPolicy = value;
		}
	}

	override protected function measure():void
	{
		measuredMinWidth = contentView.minWidth + border.contentInsets.width;
        measuredWidth = contentView.getExplicitOrMeasuredWidth() + border.contentInsets.width;

        measuredMinHeight = contentView.minHeight + border.contentInsets.height;
        measuredHeight = contentView.getExplicitOrMeasuredHeight() + border.contentInsets.height;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		contentView.setActualSize(w - border.contentInsets.width, h - border.contentInsets.height);

		var g:Graphics = graphics;
		g.clear();
		border.draw(null, g, w, h);
	}
}
}