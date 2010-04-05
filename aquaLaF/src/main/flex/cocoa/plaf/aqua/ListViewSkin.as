package cocoa.plaf.aqua
{
import cocoa.FlexDataGroup;
import cocoa.LightFlexUIComponent;
import cocoa.ScrollView;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;

public class ListViewSkin extends LightFlexUIComponent
{
	private static const STROKE_THICKNESS:Number = 1;

	public var scrollView:ScrollView;
	public var dataGroup:FlexDataGroup;

	override protected function createChildren():void
	{
		if (scrollView == null)
		{
			dataGroup = new FlexDataGroup();

			scrollView = new ScrollView();
			scrollView.hasFocusableChildren = false;
			scrollView.documentView = dataGroup;

			scrollView.move(STROKE_THICKNESS, STROKE_THICKNESS);

			addChild(scrollView);
		}
	}

	override protected function measure():void
	{
		var chromeSize:Number = STROKE_THICKNESS * 2;

		measuredMinWidth = scrollView.getMinBoundsWidth() + chromeSize;
        measuredWidth = scrollView.getPreferredBoundsWidth() + chromeSize;

        measuredMinHeight = scrollView.getMinBoundsHeight() + chromeSize;
        measuredHeight = scrollView.getPreferredBoundsHeight() + chromeSize;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		scrollView.setActualSize(w - (STROKE_THICKNESS * 2), h - (STROKE_THICKNESS * 2));

		var g:Graphics = graphics;
		g.clear();

		const left:Number = 0.5;
		const top:Number = 0.5;
		const right:Number = w - 0.5;
		const bottom:Number = h - 0.5;

		g.beginFill(0xffffff);
		g.lineStyle(1, 0xbebebe, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
		g.moveTo(left, top);
		g.lineTo(left, bottom);
		g.lineTo(right, bottom);
		g.lineTo(right, top);

		g.lineStyle(1, 0x8e8e8e, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE);
		g.lineTo(left, top);

		g.endFill();
	}
}
}