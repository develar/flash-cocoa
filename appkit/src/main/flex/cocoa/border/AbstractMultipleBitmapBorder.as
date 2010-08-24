package cocoa.border
{
import flash.display.BitmapData;
import flash.utils.ByteArray;

public class AbstractMultipleBitmapBorder extends AbstractBitmapBorder implements MultipleBorder
{
	protected var bitmaps:Vector.<BitmapData>;

	protected var _bitmapIndex:int = 0;
	public function set bitmapIndex(value:int):void
	{
		_bitmapIndex = value;
	}

	public function set stateIndex(value:int):void
	{
		throw new Error("abstract");
	}

	override public function readExternal(input:ByteArray):void
	{
		const n:int = input.readUnsignedByte();
		bitmaps = new Vector.<BitmapData>(n, true);
		for (var i:int = 0; i < n; i++)
		{
			const width:int = input.readUnsignedByte();
			if (width != 0)
			{
				var bitmapData:BitmapData = new BitmapData(width, input.readUnsignedByte(), true, 0);
				bitmapData.setPixels(bitmapData.rect, input);
				bitmaps[i] = bitmapData;
			}
		}

		super.readExternal(input);
	}

	override public function writeExternal(output:ByteArray):void
	{
		output.writeByte(bitmaps.length);
		for each (var bitmap:BitmapData in bitmaps)
		{
			if (bitmap == null)
			{
				output.writeByte(0);
			}
			else
			{
				output.writeByte(bitmap.width);
				output.writeByte(bitmap.height);
				output.writeBytes(bitmap.getPixels(bitmap.rect));
			}
		}

		super.writeExternal(output);
	}

	// for debug purposes only
	public final function getBitmaps():Vector.<BitmapData>
	{
		return bitmaps;
	}

	public function hasState(stateIndex:int):Boolean
	{
		return true;
	}
}
}