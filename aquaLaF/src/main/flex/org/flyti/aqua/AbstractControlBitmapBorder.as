package org.flyti.aqua
{
import flash.utils.ByteArray;
import flash.utils.IDataOutput;

import cocoa.TextInsets;

internal class AbstractControlBitmapBorder extends AbstractBorder
{
	protected var _layoutHeight:Number;
	public function get layoutHeight():Number
	{
		return _layoutHeight;
	}

	protected var _textInsets:TextInsets;
	public function get textInsets():TextInsets
	{
		return _textInsets;
	}

	override public function readExternal(input:ByteArray):void
	{
		super.readExternal(input);

		_layoutHeight = input.readUnsignedByte();
		
		_textInsets = new TextInsets(input.readByte(), input.readByte(), input.readByte());
	}

	override public function writeExternal(output:IDataOutput):void
	{
		super.writeExternal(output);

		output.writeByte(_layoutHeight);

		output.writeByte(_textInsets.left);
		output.writeByte(_textInsets.right);
		output.writeByte(_textInsets.bottom);
	}
}
}