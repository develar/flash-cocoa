package cocoa.graphics
{
import flash.display.BitmapData;
import flash.display.CapsStyle;
import flash.display.Graphics;
import flash.display.JointStyle;
import flash.display.LineScaleMode;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import spark.primitives.supportClasses.GraphicElement;

public class DashedRectangle extends GraphicElement
{
	private var dash:BitmapData;
	private var matrix:Matrix = new Matrix();

	private var lineThickness:Number = 1;
	private var halfLineThickness:Number;

	public function DashedRectangle()
	{
		super();

		dash = new BitmapData(4, 1, true, 0);
		dash.fillRect(new Rectangle(0, 0, 3, 1), 0xff80ace8);

		halfLineThickness = lineThickness / 2;

		matrix.tx = -lineThickness;
		matrix.ty = -halfLineThickness;
	}

	override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
	{
		if (!drawnDisplayObject || !(drawnDisplayObject is Sprite))
		{
            return;
		}

        var g:Graphics = Sprite(drawnDisplayObject).graphics;

		g.lineStyle(lineThickness, 0, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.MITER);

		// horizontal top line
		matrix.rotate(0);
		matrix.tx = x;
		matrix.ty = y;

		g.lineBitmapStyle(dash, matrix);
		const wl:Number = x + unscaledWidth + lineThickness;
		g.moveTo(x - lineThickness, y - halfLineThickness);
		g.lineTo(wl, y - halfLineThickness);
		// horizontal bottom line
		const hhl:Number = y + unscaledHeight + halfLineThickness;
		g.moveTo(x - lineThickness, hhl);
		g.lineTo(wl, hhl);

		// vertical left line
		matrix.rotate(Math.PI / 2);
		g.lineBitmapStyle(dash, matrix);
		matrix.rotate(- (Math.PI / 2));
		const hl:Number = y + unscaledHeight + lineThickness;
		g.moveTo(x - halfLineThickness, y - lineThickness);
		g.lineTo(x - halfLineThickness, hl);
		// vertical right line
		const whl:Number = x + unscaledWidth + halfLineThickness;
		g.moveTo(whl, y - lineThickness);
		g.lineTo(whl, hl);

		// Черточка состоит из собственно черточки и пробела. Так вот конец горизонтальной и вертикальной линии тут сходятся, и gap обоих может наложиться, так что мы зарисовываем его
		g.lineStyle(lineThickness, 0x80ace8, 1, false, LineScaleMode.NORMAL, CapsStyle.NONE, JointStyle.MITER);
		g.moveTo(wl - 1, hhl);
		g.lineTo(wl, hhl);
	}
}
}