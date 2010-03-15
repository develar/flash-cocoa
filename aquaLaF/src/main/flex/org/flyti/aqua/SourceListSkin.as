package org.flyti.aqua
{
import flash.display.Graphics;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsStroke;
import flash.display.IGraphicsData;

import mx.core.ILayoutElement;

import org.flyti.layout.AdvancedLayout;
import org.flyti.layout.LayoutMetrics;
import cocoa.AbstractSkin;
import cocoa.Container;
import cocoa.UIPartProvider;
import cocoa.sidebar.SourceListView;

public class SourceListSkin extends AbstractSkin implements AdvancedLayout, UIPartProvider
{
	private static const STROKE_THICKNESS:Number = 1;
	private static const STROKE_OFFSET:Number = STROKE_THICKNESS / 2;

	private static const fill:GraphicsSolidFill = new GraphicsSolidFill(0xd6dde5);

	private static const rightEdgeStroke:GraphicsStroke = new GraphicsStroke(STROKE_THICKNESS);
	rightEdgeStroke.fill = new GraphicsSolidFill(0xa5a5a5);

	public var hostComponent:SourceListView;

	private var contentGroup:Container;

	public function SourceListSkin()
	{
		super();

		width = 136;
	}

	override public function set layoutMetrics(value:LayoutMetrics):void
	{
		super.layoutMetrics = value;
		if (isNaN(_layoutMetrics.percentHeight))
		{
			_layoutMetrics.percentHeight = 100;
		}
	}

	override protected function createChildren():void
	{
		if (contentGroup == null)
		{
			contentGroup = new Container();
			addChild(contentGroup);
			hostComponent.uiPartAdded("contentGroup", contentGroup);
		}
	}

	public function childCanSkipMeasurement(element:ILayoutElement):Boolean
	{
		return true;
	}

	override protected function measure():void
	{
		measuredMinWidth = 136;
		measuredMinHeight = contentGroup.minHeight;

		measuredWidth = 136;
		measuredHeight = 0;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var g:Graphics = graphics;
		g.clear();

		const left:Number = STROKE_OFFSET;
		const top:Number = STROKE_OFFSET;
		const right:Number = w - STROKE_OFFSET;
		const bottom:Number = h - STROKE_OFFSET;

		g.drawGraphicsData(new <IGraphicsData>[fill]);
		g.moveTo(left, top);
		g.lineTo(right, top);

		g.drawGraphicsData(new <IGraphicsData>[rightEdgeStroke]);
		g.lineTo(right, bottom);

		g.lineStyle();
		g.lineTo(left, bottom);
		g.lineTo(left, top);

		g.endFill();

		contentGroup.setActualSize(w - STROKE_THICKNESS, h);
	}
}
}