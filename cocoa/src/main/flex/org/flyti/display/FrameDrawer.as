package org.flyti.display
{
import flash.display.Graphics;
import flash.display.GraphicsPath;
import flash.display.GraphicsPathCommand;
import flash.display.GraphicsSolidFill;
import flash.display.GraphicsStroke;
import flash.display.IGraphicsData;
import flash.display.IGraphicsFill;

public class FrameDrawer
{
	private static const pathCommands:Vector.<int> = new Vector.<int>(5, true);
	pathCommands[0] = GraphicsPathCommand.MOVE_TO;
	pathCommands[1] = GraphicsPathCommand.LINE_TO;
	pathCommands[2] = GraphicsPathCommand.LINE_TO;
	pathCommands[3] = GraphicsPathCommand.LINE_TO;
	pathCommands[4] = GraphicsPathCommand.LINE_TO;

	private static const pathData:Vector.<Number> = new Vector.<Number>(10, true);

	private static const graphicsData:Vector.<IGraphicsData> = new Vector.<IGraphicsData>(3, true);
	graphicsData[2] = new GraphicsPath(pathCommands, pathData);

	private var strokeThickness:Number;
	private var strokeOffset:Number;

	private var stroke:GraphicsStroke = new GraphicsStroke(2);
	private var fill:IGraphicsData;

	public static function createInset(strokeThickness:Number, strokeFillColor:uint, fill:IGraphicsFill = null):FrameDrawer
	{
		var drawer:FrameDrawer = new FrameDrawer(strokeThickness, strokeFillColor, fill);
		drawer.strokeOffset = strokeThickness / 2;
		return drawer;
	}

	public static function createSolid(strokeThickness:Number, strokeFillColor:uint, fill:IGraphicsFill = null):FrameDrawer
	{
		var drawer:FrameDrawer = new FrameDrawer(strokeThickness, strokeFillColor, fill);
		drawer.strokeOffset = 0;
		return drawer;
	}

	public function FrameDrawer(strokeThickness:Number, strokeFillColor:uint, fill:IGraphicsFill = null)
	{
		this.strokeThickness = strokeThickness;

		stroke = new GraphicsStroke(strokeThickness);
		stroke.fill = new GraphicsSolidFill(strokeFillColor);

		this.fill = IGraphicsData(fill);
	}

	public function draw(g:Graphics, w:Number, h:Number):void
	{
		const left:Number = strokeOffset;
		const top:Number = strokeOffset;
		const right:Number = w - strokeOffset;
		const bottom:Number = h - strokeOffset;

		graphicsData[0] = fill;
		graphicsData[1] = stroke;

		pathData[0] = left;
		pathData[1] = top;
		pathData[2] = right;
		pathData[3] = top;
		pathData[4] = right;
		pathData[5] = bottom;
		pathData[6] = left;
		pathData[7] = bottom;
		pathData[8] = left;
		pathData[9] = top;

		g.drawGraphicsData(graphicsData);
	}
}
}