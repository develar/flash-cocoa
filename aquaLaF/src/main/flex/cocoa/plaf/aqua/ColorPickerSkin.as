package cocoa.plaf.aqua
{
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.Graphics;
import flash.geom.Matrix;

import mx.skins.ProgrammaticSkin;

public class ColorPickerSkin extends ProgrammaticSkin
{
	private static var sharedMatrix:Matrix = new Matrix();

	private static const topRectFillBitmapData:BitmapData = new BitmapData(1, 4, false);
	topRectFillBitmapData.setVector(topRectFillBitmapData.rect, new <uint>[0xfffbfbfb, 0xfff2f2f2, 0xffe4e4e4, 0xffe9e9e9]);

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var g:Graphics = graphics;
		g.clear();

		// 2 горизонтальных линии внешней границы
		g.lineStyle(1, 0x979ca0);
		// top
		g.lineTo(w, 0);
		// bottom
		g.moveTo(0, h - 0.5);
		g.lineTo(w, h - 0.5);

		// 2 вертикальных линии внешней границы
		sharedMatrix.createGradientBox(1, h, 90 * (Math.PI / 180));
		g.lineGradientStyle(GradientType.LINEAR, [0x979ca0, 0x909499, 0x90959a, 0x979ca0], [1, 1, 1, 1], [0, 127, 128, 255], sharedMatrix);
		// left
		g.moveTo(0, 0);
		g.lineTo(0, h);
		// right
		g.moveTo(w - 1, 0);
		g.lineTo(w - 1, h);

		// заливка 4 прямоугольниками
		// top rect
		g.lineStyle();
		sharedMatrix.identity();
		sharedMatrix.tx = 1;
		sharedMatrix.ty = 1;
		g.beginBitmapFill(topRectFillBitmapData, sharedMatrix);
		g.drawRect(1, 1, w - 2, 4);
		g.endFill();

		var middleRectGradientColors:Array = [0xe9e9e9, 0xf8f8f8];
		// middle left rect
		var tx:Number = 1;
		var ty:Number = 1 + 4;
		var height:Number = h - 1 - 4 - ty;
		sharedMatrix.createGradientBox(4, height, 90 * (Math.PI / 180), tx, ty);
		g.beginGradientFill(GradientType.LINEAR, middleRectGradientColors, [1, 1], [0, 255], sharedMatrix);
		g.drawRect(tx, ty, 4, height);
		g.endFill();


		// middle right rect
		tx = w - 4 - 1;
		sharedMatrix.createGradientBox(4, height, 90 * (Math.PI / 180), tx, ty);
		g.beginGradientFill(GradientType.LINEAR, middleRectGradientColors, [1, 1], [0, 255], sharedMatrix);
		g.drawRect(tx, ty, 4, height);
		g.endFill();

		// bottom rect
		tx = 1;
		ty = h - 5;
		sharedMatrix.createGradientBox(w - 2, 4, 90 * (Math.PI / 180), tx, ty);
		g.beginGradientFill(GradientType.LINEAR, [0xf8f8f8, 0xf9f9f9], [1, 1], [0, 255], sharedMatrix);
		g.drawRect(tx, ty, w - 2, 4);
		g.endFill();

		// inner border
		g.lineStyle(1, 0x8a8a8a);
		g.drawRect(5, 5, w - 5 - 5 - 1, h - 5 - 5 - 1);
	}
}
}