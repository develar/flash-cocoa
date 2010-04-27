package cocoa.data
{
import flash.display.BitmapData;

public final class BitmapDataCache extends AbstractCache
{
	private var hits:Vector.<BitmapDataCacheItem> = new Vector.<BitmapDataCacheItem>();

	public function BitmapDataCache(maxSize:int)
	{
		this.maxSize = maxSize;
	}

	public function get(key:String):BitmapData
	{
		var item:BitmapDataCacheItem = data[key];
		if (item == null)
		{
			return null;
		}

		var hitIndex:int = item.hitIndex;
		if (hitIndex > 0)
		{
			var prevItem:BitmapDataCacheItem = hits[hitIndex - 1];
			prevItem.hitIndex = hitIndex;
			item.hitIndex = hitIndex - 1;
			hits[hitIndex] = prevItem;
			hits[hitIndex - 1] = item;
		}

		return item.bitmapData;
	}

	public function put(key:String, bitmapData:BitmapData):void
	{
		var size:int = (bitmapData.width * bitmapData.height) << 2;
		currentSize += size;

		var item:BitmapDataCacheItem;
		var hitIndex:int;
		if (currentSize > maxSize)
		{
			var excess:int = currentSize - maxSize;
			for (var i:int = hits.length - 1; excess > 0 && i > -1; i--)
			{
				item = hits[i];
				excess -= item.size;
				delete data[item.key];
			}

			hitIndex = i + 1; // тут i индекс того элемента, что не был удален из-за невыполнения условия excess > 0, то есть мы прибавляем 1 чтобы быть добавленным после него
			hits.length = hitIndex + 1;
			currentSize = maxSize + excess;

			// размещаем новый в середину, чтобы при следующей вставке он не был удален сразу же при чистке (а это будет, если мы просто поместим в конец)
			var middleIndex:int = hitIndex >> 1;
			var middleItem:BitmapDataCacheItem = hits[middleIndex];
			middleItem.hitIndex = hitIndex;
			hits[hitIndex] = middleItem;

			hitIndex = middleIndex;

			item.key = key;
			item.bitmapData = bitmapData;
			item.size = size;
			item.hitIndex = hitIndex;
		}
		else
		{
			hitIndex = hits.length++;
			item = new BitmapDataCacheItem(key, bitmapData, size, hitIndex);
		}

		hits[hitIndex] = item;
		data[key] = item;
	}
}
}