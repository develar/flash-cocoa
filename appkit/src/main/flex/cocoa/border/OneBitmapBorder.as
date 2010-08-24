package cocoa.border
{
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.utils.ByteArray;

public class OneBitmapBorder extends AbstractBitmapBorder
{
	private var bitmap:BitmapData;

	// for debug purposes only
	public final function getBitmap():BitmapData
	{
		return bitmap;
	}

	private var _layoutWidth:Number;
	override public function get layoutWidth():Number
	{
		return _layoutWidth;
	}

	private var _layoutHeight:Number;
	override public function get layoutHeight():Number
	{
		return _layoutHeight;
	}

	public static function create(bitmap:BitmapData, contentInsets:Insets = null, frameInsets:FrameInsets = null):OneBitmapBorder
	{
		var border:OneBitmapBorder = new OneBitmapBorder();
		border.bitmap = bitmap;
		if (contentInsets != null)
		{
			border._contentInsets = contentInsets;
		}
		if (frameInsets != null)
		{
			border._frameInsets = frameInsets;
		}

		border._layoutHeight = bitmap.height + border._frameInsets.top + border._frameInsets.bottom;
		border._layoutWidth = bitmap.width + border._frameInsets.left + border._frameInsets.right;
		return border;
	}

	public static function createByBitmapClass(bitmapClass:Class, contentInsets:Insets = null, frameInsets:FrameInsets = null):OneBitmapBorder
	{
		return create(Bitmap(new bitmapClass()).bitmapData, contentInsets, frameInsets);
	}

	override public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		sharedMatrix.tx = _frameInsets.left;
		sharedMatrix.ty = _frameInsets.top;

		g.beginBitmapFill(bitmap, sharedMatrix, false);
		g.drawRect(_frameInsets.left, _frameInsets.top, w - _frameInsets.left - _frameInsets.right, h - _frameInsets.bottom - _frameInsets.top);
		g.endFill();
	}

	override public function writeExternal(output:ByteArray):void
	{
		output.writeByte(3);

		output.writeByte(bitmap.width);
		output.writeByte(bitmap.height);
		output.writeBytes(bitmap.getPixels(bitmap.rect));

		super.writeExternal(output);

		lazyWriteFrameInsets(output);
	}

	override public function readExternal(input:ByteArray):void
	{
		bitmap = new BitmapData(input.readUnsignedByte(), input.readUnsignedByte(), true, 0);
		bitmap.setPixels(bitmap.rect, input);

		super.readExternal(input);

		lazyReadFrameInsets(input);

		_layoutHeight = bitmap.height + _frameInsets.top + _frameInsets.bottom;
		_layoutWidth = bitmap.width + _frameInsets.left + _frameInsets.right;
	}
}
}