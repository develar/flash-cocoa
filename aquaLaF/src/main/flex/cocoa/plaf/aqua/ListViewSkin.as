package cocoa.plaf.aqua
{
import cocoa.AbstractView;
import cocoa.LightFlexUIComponent;

import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;

import mx.core.ScrollPolicy;

import spark.components.DataGroup;
import spark.components.Scroller;

public class ListViewSkin extends LightFlexUIComponent
{
	private static const STROKE_THICKNESS:Number = 1;

	public var scroller:Scroller;
	public var dataGroup:DataGroup;

	override protected function createChildren():void
	{
		if (scroller == null)
		{
			scroller = new Scroller();
			scroller.hasFocusableChildren = false;

			dataGroup = new DataGroup();
			scroller.viewport = dataGroup;

			scroller.move(STROKE_THICKNESS, STROKE_THICKNESS);
			scroller.setStyle("verticalScrollPolicy", ScrollPolicy.AUTO);
			scroller.setStyle("horizontalScrollPolicy", ScrollPolicy.AUTO);
			scroller.setStyle("layoutDirection", AbstractView.LAYOUT_DIRECTION_LTR);

			//var layout:LayoutBase = List(owner).layout;
			//scroller.minViewportInset = (layout is TileLayout ? TileLayout(layout).horizontalGap : VerticalLayout(layout).gap) / 2;

			addChild(scroller);
		}
	}

	override protected function measure():void
	{
		var chromeSize:Number = STROKE_THICKNESS * 2;

		measuredMinWidth = scroller.getMinBoundsWidth() + chromeSize;
        measuredWidth = scroller.getPreferredBoundsWidth() + chromeSize;

        measuredMinHeight = scroller.getMinBoundsHeight() + chromeSize;
        measuredHeight = scroller.getPreferredBoundsHeight() + chromeSize;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
//		scroller.setActualSize(w - (STROKE_THICKNESS * 2), h - (STROKE_THICKNESS * 2));
		scroller.setLayoutBoundsPosition(STROKE_THICKNESS, STROKE_THICKNESS);
		scroller.setLayoutBoundsSize(w - (STROKE_THICKNESS * 2), h - (STROKE_THICKNESS * 2));

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