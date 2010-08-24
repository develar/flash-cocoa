package cocoa.border
{
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.TextInsets;
import cocoa.plaf.*;

import flash.geom.Matrix;
import flash.utils.ByteArray;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;

public class AbstractBitmapBorder extends AbstractBorder implements ExternalizableResource
{
	protected static const sharedMatrix:Matrix = new Matrix();

	public function readExternal(input:ByteArray):void
	{
		if (input.readByte() == 1)
		{
			_contentInsets = readInsets(input);
		}
	}

	public function writeExternal(output:ByteArray):void
	{
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

	protected final function writeInsets(output:IDataOutput, insets:Insets):void
	{
		output.writeByte(insets is TextInsets ? TextInsets(insets).truncatedTailMargin : -1);
		output.writeByte(insets.left);
		output.writeByte(insets.top);
		output.writeByte(insets.right);
		output.writeByte(insets.bottom);
	}

	protected final function readInsets(input:IDataInput):Insets
	{
		var first:int = input.readByte();
		return first == -1 ? new Insets(input.readByte(), input.readByte(), input.readByte(), input.readByte()) : new TextInsets(first, input.readByte(), input.readByte(), input.readByte(), input.readByte());
	}

	protected final function readFrameInsets(input:IDataInput):FrameInsets
	{
		return new FrameInsets(input.readByte(), input.readByte(), input.readByte(), input.readByte());
	}

	protected final function lazyReadFrameInsets(input:IDataInput):void
	{
		if (input.readByte() == 1)
		{
			_frameInsets = readFrameInsets(input);
		}
	}

	protected final function writeFrameInsets(output:IDataOutput):void
	{
		output.writeByte(_frameInsets.left);
		output.writeByte(_frameInsets.top);
		output.writeByte(_frameInsets.right);
		output.writeByte(_frameInsets.bottom);
	}

	protected final function lazyWriteFrameInsets(output:IDataOutput):void
	{
		if (_frameInsets == EMPTY_FRAME_INSETS)
		{
			output.writeByte(0);
		}
		else
		{
			output.writeByte(1);
			writeFrameInsets(output);
		}
	}
}
}