package cocoa.plaf
{
import flash.utils.ByteArray;

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

		_layoutHeight = input.readUnsignedByte();
		_contentInsets = readInsets(input);


	}

	override public function writeExternal(output:ByteArray):void
	{
		super.writeExternal(output);

		output.writeByte(_layoutHeight);
		writeInsets(output, _contentInsets);
	}
}
}