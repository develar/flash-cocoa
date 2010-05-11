package cocoa.colorPicker
{
import flash.display.GradientType;
import flash.display.Graphics;
import flash.geom.Matrix;

import mx.skins.ProgrammaticSkin;

public class ColorPickerSkin extends ProgrammaticSkin
{
	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var g:Graphics = graphics;
		g.clear();

		g.lineStyle(1, 0x979ca0);
		g.lineTo(w, 0);
		g.moveTo(0, h - 0.5);
		g.lineTo(w, h - 0.5);

		var matrix:Matrix = new Matrix();
		matrix.createGradientBox(1, h, 90 * (Math.PI / 180));
		g.lineGradientStyle(GradientType.LINEAR, [0x979ca0, 0x909499, 0x90959a, 0x979ca0], [1, 1, 1, 1], [0, 127, 128, 255], matrix);
		g.moveTo(0, 0);
		g.lineTo(0, h);

		g.moveTo(w - 1, 0);
		g.lineTo(w - 1, h);

		g.lineStyle();
		matrix.createGradientBox(4, h - 2, 90 * (Math.PI / 180), 1, 1);
		g.beginGradientFill(GradientType.LINEAR, [0xf7f7f8, 0xf5f5f5], [1, 1], [0, 255], matrix);
		g.drawRect(matrix.tx, 1, 4, h - 2);
		g.endFill();

		matrix.tx = w - 4 - 1;
		g.beginGradientFill(GradientType.LINEAR, [0xf7f7f8, 0xf5f5f5], [1, 1], [0, 255], matrix);
		g.drawRect(matrix.tx, 1, 4, h - 2);
		g.endFill();
	}
}
}