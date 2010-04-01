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
 * Повторение в beginBitmapFill отключено. Данный border не предназначен для повторения фрагмента большего чем 1px —
 * то есть в первую очередь используется для, к примеру — отображения 5px уникального неповторимого изображения и повторяемого шириной (или высотой в зависимости от ориентации) 1px
 * ("If false, the bitmap image does not repeat, and the edges of the bitmap are used for any fill area that extends beyond the bitmap.")
 */
public final class Scale1BitmapBorder extends AbstractControlBitmapBorder implements Border
{
	private var _layoutWidth:Number;
	override public function get layoutWidth():Number
	{
		return _layoutWidth;
	}

	public static function create(bitmaps:Vector.<BitmapData>, contentInsets:Insets = null, frameInsets:FrameInsets = null):Scale1BitmapBorder
	{
		var border:Scale1BitmapBorder = new Scale1BitmapBorder();
		border.bitmaps = bitmaps;
		if (contentInsets != null)
		{
			border._contentInsets = contentInsets;
		}
		if (frameInsets != null)
		{
			border._frameInsets = frameInsets;
		}

		border._layoutHeight = bitmaps[0].height + border._frameInsets.top + border._frameInsets.bottom;
		border._layoutWidth = bitmaps[0].width + border._frameInsets.left + border._frameInsets.right;
		return border;
	}

	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		sharedMatrix.tx = _frameInsets.left;
		sharedMatrix.ty = _frameInsets.top;

		g.beginBitmapFill(bitmaps[_bitmapIndex], sharedMatrix, false);
		g.drawRect(_frameInsets.left, _frameInsets.top, w, h - _frameInsets.bottom);
		g.endFill();
	}

	override public function readExternal(input:ByteArray):void
	{
		super.readExternal(input);

		if (input.readByte() == 1)
		{
			_frameInsets = readFrameInsets(input);
		}
		
		_layoutHeight = bitmaps[0].height + _frameInsets.top + _frameInsets.bottom;
		_layoutWidth = bitmaps[0].width + _frameInsets.left + _frameInsets.right;
	}

	override public function writeExternal(output:ByteArray):void
	{
		output.writeByte(1);

		super.writeExternal(output);

		if (frameInsets == EMPTY_FRAME_INSETS)
		{
			output.writeByte(0);
		}
		else
		{
			output.writeByte(1);
			writeFrameInsets(output, _frameInsets);
		}
	}

	public function set frameInsets(value:FrameInsets):void
	{
		_frameInsets = value;
	}
}
}