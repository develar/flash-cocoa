package cocoa.plaf
{
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.utils.ByteArray;

/**
 * Фиксированная высота, произвольная ширина — масштабируется только по горизонтали.
 * Состоит из left, center и right кусочков bitmap — left и right как есть, а повторяется только center.
 * Реализовано как две bitmap, где 1 это склееный left и center — ширина center равна 1px — мы используем "the bitmap image does not repeat, and the edges of the bitmap are used for any fill area that extends beyond the bitmap"
 * (это позволяет нам сократить количество bitmapData, количество вызовов на отрисовку и в целом немного упростить код (в частности, для тех случаев, когда left width == 0)).
 */
public class Scale3HBitmapBorder extends AbstractScale3BitmapBorder
{
	public static function create(frameInsets:FrameInsets, contentInsets:Insets = null):Scale3HBitmapBorder
	{
		var border:Scale3HBitmapBorder = new Scale3HBitmapBorder();
		border.init(frameInsets, contentInsets);
		return border;
	}

	public function configure(bitmaps:Vector.<BitmapData>):void
	{
		this.bitmaps = bitmaps;

		lastSize = bitmaps[1].width;

		size = bitmaps[0].height;
		_layoutHeight = size + _frameInsets.top + _frameInsets.bottom;
	}

	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		sharedMatrix.tx = _frameInsets.left;
		sharedMatrix.ty = _frameInsets.top;

		var rightSliceX:Number = w - lastSize - _frameInsets.right;
		g.beginBitmapFill(bitmaps[_bitmapIndex], sharedMatrix, false);
		g.drawRect(sharedMatrix.tx, sharedMatrix.ty, rightSliceX - _frameInsets.left, size);
		g.endFill();

		sharedMatrix.tx = rightSliceX;
		g.beginBitmapFill(bitmaps[_bitmapIndex + 1], sharedMatrix, false);
		g.drawRect(rightSliceX, sharedMatrix.ty, lastSize, size);
		g.endFill();
	}

	override public function readExternal(input:ByteArray):void
	{
		super.readExternal(input);

		lastSize = bitmaps[1].width;
		size = bitmaps[0].height;
		_layoutHeight = size + _frameInsets.top + _frameInsets.bottom;
	}
}
}