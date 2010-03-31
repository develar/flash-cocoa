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

		_contentInsets = readInsets(input);
	}

	override public function writeExternal(output:ByteArray):void
	{
		super.writeExternal(output);

		writeInsets(output, _contentInsets);
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