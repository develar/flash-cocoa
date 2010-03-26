package cocoa.plaf
{
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.utils.ByteArray;

// frameInsets не пишется, не нужно
public final class Scale1HBitmapBorder extends AbstractControlBitmapBorder implements Border
{
	public static function create(bitmaps:Vector.<BitmapData>, layoutHeight:Number, contentInsets:Insets, frameInsets:FrameInsets = null):Scale1HBitmapBorder
	{
		var border:Scale1HBitmapBorder = new Scale1HBitmapBorder();
		border.bitmaps = bitmaps;
		border._layoutHeight = layoutHeight;
		border._contentInsets = contentInsets;
		if (frameInsets != null)
		{
			border._frameInsets = frameInsets;
		}
		return border;
	}

	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		sharedMatrix.tx = _frameInsets.left;
		sharedMatrix.ty = 0;

		g.beginBitmapFill(bitmaps[_bitmapIndex], sharedMatrix, true);
		g.drawRect(_frameInsets.left, 0, w, h - _frameInsets.bottom);
		g.endFill();
	}

	public function drawSeries(g:Graphics, w:Number, h:Number):void
	{
		sharedMatrix.tx = frameInsets.left;
		sharedMatrix.ty = 0;
	}

//	override public function readExternal(input:ByteArray):void
//	{
//		super.readExternal(input);
//
//		if (input.readByte() == 1)
//		{
//			_frameInsets = new FrameInsets(input.readByte(), 0, input.readByte());
//		}
//	}

	override public function writeExternal(output:ByteArray):void
	{
		output.writeByte(1);

		super.writeExternal(output);

//		if (frameInsets == EMPTY_FRAME_INSETS)
//		{
//			output.writeByte(0);
//		}
//		else
//		{
//			output.writeByte(1);
//			output.writeByte(_frameInsets.left);
//			output.writeByte(_frameInsets.right);
//		}
	}

	public function set frameInsets(value:FrameInsets):void
	{
		_frameInsets = value;
	}
}
}