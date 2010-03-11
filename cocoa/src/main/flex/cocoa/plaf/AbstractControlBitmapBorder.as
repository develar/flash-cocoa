package cocoa.plaf
{
import cocoa.Insets;

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
		
		_contentInsets = new Insets(input.readByte(), NaN, input.readByte(), input.readByte());
	}

	override public function writeExternal(output:ByteArray):void
	{
		super.writeExternal(output);

		output.writeByte(_layoutHeight);

		output.writeByte(_contentInsets.left);
		output.writeByte(_contentInsets.right);
		output.writeByte(_contentInsets.bottom);
	}
}
}