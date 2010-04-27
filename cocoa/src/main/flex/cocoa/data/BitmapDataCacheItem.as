package cocoa.data
{
import flash.display.BitmapData;

internal final class BitmapDataCacheItem extends AbstractCacheItem
{
	public var bitmapData:BitmapData;

	public function BitmapDataCacheItem(key:String, bitmapData:BitmapData, size:int, hitIndex:int)
	{
		this.key = key;
		this.bitmapData = bitmapData;
		this.size = size;
		this.hitIndex = hitIndex;
	}
}
}