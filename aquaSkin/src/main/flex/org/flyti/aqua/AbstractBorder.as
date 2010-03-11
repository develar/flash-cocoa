package org.flyti.aqua
{
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.utils.ByteArray;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;

import org.flyti.view.Border;
import org.flyti.view.Insets;

internal class AbstractBorder implements Border
{
	protected static const sharedMatrix:Matrix = new Matrix();

	protected var bitmaps:Vector.<BitmapData>;

	public function readExternal(input:ByteArray):void
	{
		var n:int = input.readUnsignedByte();
		bitmaps = new Vector.<BitmapData>(n, true);
		for (var i:int = 0; i < n; i++)
		{
			var bitmapData:BitmapData = new BitmapData(input.readUnsignedByte(), input.readUnsignedByte(), true, 0);
			bitmapData.setPixels(bitmapData.rect, input);
			bitmaps[i] = bitmapData;
		}
	}

	public function writeExternal(output:IDataOutput):void
	{
		output.writeByte(bitmaps.length);
		for each (var bitmap:BitmapData in bitmaps)
		{
			output.writeByte(bitmap.width);
			output.writeByte(bitmap.height);
			output.writeBytes(bitmap.getPixels(bitmap.rect));
		}
	}

	protected final function readInsets(input:IDataInput):Insets
	{
		return new Insets(input.readByte(), input.readByte(), input.readByte(), input.readByte());
	}

	protected final function writeInsets(output:IDataOutput, insets:Insets):void
	{
		output.writeByte(insets.left);
		output.writeByte(insets.top);
		output.writeByte(insets.right);
		output.writeByte(insets.bottom);
	}

	// for debug purposes only
	internal final function getBitmaps():Vector.<BitmapData>
	{
		return bitmaps;
	}
}
}