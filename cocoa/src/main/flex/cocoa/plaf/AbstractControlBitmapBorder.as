package cocoa.plaf
{
import cocoa.FrameInsets;

import flash.utils.ByteArray;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;

internal class AbstractControlBitmapBorder extends AbstractBitmapBorder
{
	protected var _layoutHeight:Number;
	override public function get layoutHeight():Number
	{
		return _layoutHeight;
	}

	override public function readExternal(input:ByteArray):void
	{
		super.readExternal(input);

		if (input.readByte() == 1)
		{
			_contentInsets = readInsets(input);
		}
	}

	override public function writeExternal(output:ByteArray):void
	{
		super.writeExternal(output);

		if (_contentInsets == EMPTY_CONTENT_INSETS)
		{
			output.writeByte(0);
		}
		else
		{
			output.writeByte(1);
			writeInsets(output, _contentInsets);
		}
	}

	protected final function readFrameInsets(input:IDataInput):FrameInsets
	{
		return new FrameInsets(input.readByte(), input.readByte(), input.readByte(), input.readByte());
	}

	protected final function writeFrameInsets(output:IDataOutput, insets:FrameInsets):void
	{
		output.writeByte(insets.left);
		output.writeByte(insets.top);
		output.writeByte(insets.right);
		output.writeByte(insets.bottom);
	}
}
}