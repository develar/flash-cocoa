package cocoa.plaf
{
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.BitmapData;
import flash.display.Graphics;

public class Scale3BitmapBorder extends AbstractScale3BitmapBorder
{
	protected var firstSize:Number;

	public static function create(frameInsets:FrameInsets, contentInsets:Insets = null):Scale3BitmapBorder
	{
		var border:Scale3BitmapBorder = new Scale3BitmapBorder();
		border.init(frameInsets, contentInsets);
		return border;
	}

	public function configure(bitmaps:Vector.<BitmapData>):void
	{
		this.bitmaps = bitmaps;

		size = bitmaps[0].height;
		firstSize = bitmaps[0].width;
		lastSize = bitmaps[2].width;

		_layoutHeight = size + _frameInsets.top + _frameInsets.bottom;
	}

	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		sharedMatrix.tx = _frameInsets.left;
		sharedMatrix.ty = _frameInsets.top;

		g.beginBitmapFill(bitmaps[_bitmapIndex], sharedMatrix, false);
		g.drawRect(_frameInsets.left, _frameInsets.top, firstSize, size);
		g.endFill();

		const centerSliceX:Number = sharedMatrix.tx = _frameInsets.left + firstSize;
		const rightSliceX:Number = w - lastSize - _frameInsets.right;
		g.beginBitmapFill(bitmaps[_bitmapIndex + 1], sharedMatrix, true);
		g.drawRect(centerSliceX, sharedMatrix.ty, rightSliceX - centerSliceX, size);
		g.endFill();

		sharedMatrix.tx = rightSliceX;
		g.beginBitmapFill(bitmaps[_bitmapIndex + 2], sharedMatrix, false);
		g.drawRect(rightSliceX, sharedMatrix.ty, lastSize, size);
		g.endFill();
	}
}
}