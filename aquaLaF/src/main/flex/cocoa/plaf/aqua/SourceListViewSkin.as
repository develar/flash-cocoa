package cocoa.plaf.aqua
{
import cocoa.Container;
import cocoa.layout.AdvancedLayout;
import cocoa.layout.LayoutMetrics;
import cocoa.plaf.AbstractSkin;

import flash.display.Graphics;

import mx.core.ILayoutElement;

public class SourceListViewSkin extends AbstractSkin implements AdvancedLayout
{
	private static const STROKE_THICKNESS:Number = 1;
	private static const STROKE_OFFSET:Number = STROKE_THICKNESS / 2;

	private var contentGroup:Container;

	public function SourceListViewSkin()
	{
		super();

		minWidth = 121;
	}

	override public function set layoutMetrics(value:LayoutMetrics):void
	{
		super.layoutMetrics = value;

		width = 121;
	}

	override protected function createChildren():void
	{
		if (contentGroup == null)
		{
			contentGroup = new Container();
			addChild(contentGroup);
			component.uiPartAdded("contentGroup", contentGroup);
		}
	}

	public function childCanSkipMeasurement(element:ILayoutElement):Boolean
	{
		return true;
	}

	override protected function measure():void
	{
		measuredMinHeight = contentGroup.minHeight;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var g:Graphics = graphics;
		g.clear();

		const left:Number = STROKE_OFFSET;
		const top:Number = STROKE_OFFSET;
		const right:Number = w - STROKE_OFFSET;
		const bottom:Number = h - STROKE_OFFSET;

		g.beginFill(0xdee4ea);
		g.moveTo(left, top);
		g.lineTo(right, top);

		g.lineStyle(1, 0xb4b4b4);
		g.lineTo(right, bottom);

		g.lineStyle();
		g.lineTo(left, bottom);
		g.lineTo(left, top);

		g.endFill();

		contentGroup.setActualSize(w - STROKE_THICKNESS, h);
	}
}
}