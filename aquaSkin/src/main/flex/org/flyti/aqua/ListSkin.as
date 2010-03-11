package org.flyti.aqua
{
import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.LineScaleMode;

import mx.core.UIComponent;

import org.flyti.layout.TileLayout;

import spark.components.DataGroup;
import spark.components.List;
import spark.components.Scroller;
import spark.layouts.VerticalLayout;
import spark.layouts.supportClasses.LayoutBase;

public class ListSkin extends UIComponent
{
	private static const STROKE_THICKNESS:Number = 1;

	public var scroller:Scroller;
	public var dataGroup:DataGroup;

	override public function set currentState(value:String):void
    {
    }

	override protected function createChildren():void
	{
		if (scroller == null)
		{
			scroller = new Scroller();
			scroller.hasFocusableChildren = false;

			dataGroup = new DataGroup();
			scroller.viewport = dataGroup;

			var layout:LayoutBase = List(owner).layout;
			scroller.minViewportInset = (layout is TileLayout ? TileLayout(layout).horizontalGap : VerticalLayout(layout).gap) / 2;

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