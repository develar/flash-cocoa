package cocoa.plaf
{
import cocoa.FrameInsets;
import cocoa.Insets;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.utils.ByteArray;

import mx.core.UIComponent;

/**
 * Тот же трюк, что и в Scale3HBitmapBorder — отрисовка scale9Grid требует всего 4, а не 9 кусочков
 */
public final class Scale9BitmapBorder extends AbstractBitmapBorder
{
	private var rightSliceInnerWidth:int;
	private var bottomSliceInnerHeight:int;

	public static function create(frameInsets:FrameInsets, contentInsets:Insets):Scale9BitmapBorder
	{
		var border:Scale9BitmapBorder = new Scale9BitmapBorder();
		border._frameInsets = frameInsets;
		border._contentInsets = contentInsets;
		return border;
	}

	public function configure(bitmaps:Vector.<BitmapData>):void
	{
		this.bitmaps = bitmaps;

		rightSliceInnerWidth = bitmaps[1].width + _frameInsets.right;
		bottomSliceInnerHeight = bitmaps[2].height + _frameInsets.bottom;
	}

	override public function draw(object:UIComponent, g:Graphics, w:Number, h:Number):void
	{
		sharedMatrix.tx = _frameInsets.left;
		sharedMatrix.ty = _frameInsets.top;

		const rightSliceX:Number = w - rightSliceInnerWidth;
		const bottomSliceY:Number = h - bottomSliceInnerHeight;

		const topAreaHeight:Number = bottomSliceY - _frameInsets.top;
		const bottomAreaHeight:Number = bitmaps[2].height;
		const leftAreaWidth:Number = rightSliceX - _frameInsets.left;
		const rightAreaWidth:Number = bitmaps[1].width;

		g.beginBitmapFill(bitmaps[0], sharedMatrix, false);
		g.drawRect(_frameInsets.left, sharedMatrix.ty, leftAreaWidth, topAreaHeight);
		g.endFill();

		sharedMatrix.tx = rightSliceX;
		g.beginBitmapFill(bitmaps[1], sharedMatrix, false);
		g.drawRect(rightSliceX, sharedMatrix.ty, rightAreaWidth, topAreaHeight);
		g.endFill();

		sharedMatrix.ty = bottomSliceY;

		sharedMatrix.tx = _frameInsets.left;
		g.beginBitmapFill(bitmaps[2], sharedMatrix, false);
		g.drawRect(_frameInsets.left, bottomSliceY, leftAreaWidth, bottomAreaHeight);
		g.endFill();

		sharedMatrix.tx = rightSliceX;
		g.beginBitmapFill(bitmaps[3], sharedMatrix, false);
		g.drawRect(rightSliceX, bottomSliceY, rightAreaWidth, bottomAreaHeight);
		g.endFill();
	}

	override public function readExternal(input:ByteArray):void
	{
		super.readExternal(input);

		_contentInsets = readInsets(input);
		_frameInsets = new FrameInsets(input.readByte(), input.readByte(), input.readByte(), input.readByte());

		rightSliceInnerWidth = bitmaps[1].width + _frameInsets.right;
		bottomSliceInnerHeight = bitmaps[2].height + _frameInsets.bottom;
	}

	override public function writeExternal(output:ByteArray):void
	{
		output.writeByte(2);

		super.writeExternal(output);

		writeInsets(output, _contentInsets);

		output.writeByte(_frameInsets.left);
		output.writeByte(_frameInsets.top);
		output.writeByte(_frameInsets.right);
		output.writeByte(_frameInsets.bottom);
	}
}
}