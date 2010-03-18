package cocoa.plaf
{
import cocoa.Border;
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
public final class Scale3HBitmapBorder extends AbstractControlBitmapBorder implements Border
{
	private var sliceHeight:Number;
	private var sliceSizes:Insets;

	public static function create(layoutHeight:Number, frameInsets:FrameInsets, contentInsets:Insets):Scale3HBitmapBorder
	{
		var border:Scale3HBitmapBorder = new Scale3HBitmapBorder();
		border._layoutHeight = layoutHeight;
		border._frameInsets = frameInsets;
		border._contentInsets = contentInsets;
		return border;
	}

	public function configure(sliceSizes:Insets, bitmaps:Vector.<BitmapData>):void
	{
		this.sliceSizes = sliceSizes;
		this.sliceHeight = sliceHeight;
		this.bitmaps = bitmaps;

		sliceHeight = bitmaps[0].height;
	}

	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		sharedMatrix.tx = _frameInsets.left;
		sharedMatrix.ty = _frameInsets.top;

		var rightSliceX:Number = w - sliceSizes.right - _frameInsets.right;
		g.beginBitmapFill(bitmaps[_bitmapIndex], sharedMatrix, false);
		g.drawRect(sharedMatrix.tx, sharedMatrix.ty, rightSliceX - _frameInsets.left, sliceHeight);
		g.endFill();

		sharedMatrix.tx = rightSliceX;
		g.beginBitmapFill(bitmaps[_bitmapIndex + 1], sharedMatrix, false);
		g.drawRect(rightSliceX, sharedMatrix.ty, sliceSizes.right, sliceHeight);
		g.endFill();
	}

	override public function readExternal(input:ByteArray):void
	{
		super.readExternal(input);
		
		sliceSizes = readInsets(input);
		_frameInsets = new FrameInsets(input.readByte(), input.readByte(), input.readByte());

		sliceHeight = bitmaps[0].height;
	}

	override public function writeExternal(output:ByteArray):void
	{
		output.writeByte(0);
		super.writeExternal(output);
		writeInsets(output, sliceSizes);

		output.writeByte(_frameInsets.left);
		output.writeByte(_frameInsets.top);
		output.writeByte(_frameInsets.right);
	}
}
}