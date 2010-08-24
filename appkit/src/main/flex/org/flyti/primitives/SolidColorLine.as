package org.flyti.primitives
{
import flash.display.CapsStyle;
import flash.display.GraphicsEndFill;
import flash.display.GraphicsPath;
import flash.display.GraphicsPathCommand;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsStroke;
import flash.display.IGraphicsData;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;

import spark.primitives.supportClasses.GraphicElement;

public class SolidColorLine extends GraphicElement
{
	private var graphicsData:Vector.<IGraphicsData>;
	private var pathData:Vector.<Number>;

	private var fill:GraphicsSolidFill;

	public function SolidColorLine()
	{
		var pathCommands:Vector.<int> = new Vector.<int>(2, true);
		pathCommands[0] = GraphicsPathCommand.MOVE_TO;
		pathCommands[1] = GraphicsPathCommand.LINE_TO;

		pathData = new Vector.<Number>(4, true);

		fill = new GraphicsSolidFill();

		graphicsData = new Vector.<IGraphicsData>(3, true);
		// miter joint — при round будет getBounds больше на thickness / 2
		graphicsData[0] = new GraphicsStroke(1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.MITER, 3, fill);
		graphicsData[1] = new GraphicsPath(pathCommands, pathData);
		graphicsData[2] = new GraphicsEndFill();

		super();
	}

	override public function get alpha():Number
	{
		return fill.alpha;
	}
	override public function set alpha(value:Number):void
	{
		fill.alpha = value;
	}

	public function get color():uint
	{
		return fill.color;
	}
	public function set color(value:uint):void
	{
		if (value != color)
		{
			fill.color = value;
			invalidateDisplayList();
		}
	}

	public function get thickness():Number
	{
		return GraphicsStroke(graphicsData[0]).thickness;
	}
	public function set thickness(value:Number):void
	{
		 GraphicsStroke(graphicsData[0]).thickness = value;
	}

	/**
	 * http://juick.com/386680#1
	 */
	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    {
		var scaleX:Number = this.scaleX;
		var scaleY:Number = this.scaleY;
		var thickness:Number = this.thickness;

		var actualWidth:Number = unscaledWidth;
		var adjustedDrawX:Number = drawX;
		var adjustedDrawY:Number = drawY;
//		if (stroke.scaleMode == LineScaleMode.NORMAL)
//		{
		thickness *= (scaleX == scaleY) ? scaleX : Math.sqrt(0.5 * (scaleX * scaleX + scaleY * scaleY));

		if (unscaledWidth == 0)
		{
			if (unscaledHeight != 0)
			{
				adjustedDrawX += thickness * 0.5;
			}
			if (right != null)
			{
				adjustedDrawX -= thickness;
			}
		}
		if (unscaledHeight == 0)
		{
			adjustedDrawY += thickness * 0.5;
			if (bottom != null)
			{
				adjustedDrawY -= thickness;
			}
			if (unscaledWidth == 0)
			{
				actualWidth = thickness;
			}
		}
//		}

		pathData[0] = adjustedDrawX;
		pathData[1] = adjustedDrawY;
		pathData[2] = adjustedDrawX + actualWidth;
		pathData[3] = adjustedDrawY + unscaledHeight;

		Sprite(drawnDisplayObject).graphics.drawGraphicsData(graphicsData);
	}
}
}