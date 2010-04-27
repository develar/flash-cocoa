package cocoa.data
{
import flash.display.DisplayObject;

public final class SWFCache extends AbstractCache
{
	private var hits:Vector.<SWFCacheItem> = new Vector.<SWFCacheItem>();

	public function SWFCache(maxSize:int)
	{
		this.maxSize = maxSize;
	}

	public function get(key:String):DisplayObject
	{
		var item:SWFCacheItem = data[key];
		if (item == null)
		{
			return null;
		}

		var hitIndex:int = item.hitIndex;
		if (hitIndex > 0)
		{
			var prevItem:SWFCacheItem = hits[hitIndex - 1];
			prevItem.hitIndex = hitIndex;
			item.hitIndex = hitIndex - 1;
			hits[hitIndex] = prevItem;
			hits[hitIndex - 1] = item;
		}

		return new item.clazz();
	}

	public function put(key:String, clazz:Class, size:int):void
	{
		currentSize += size;

		var item:SWFCacheItem;
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

			hitIndex = i + 1; // тут i индекс того элемента, что не был удален из-за невыполнения условия excess > 0, то есть мы прибавляем 1 чтобы быть добавленным после него;
			hits.length = hitIndex + 1;
			currentSize = maxSize + excess;

			// размещаем новый в середину, чтобы при следующей вставке он не был удален сразу же при чистке (а это будет, если мы просто поместим в конец)
			var middleIndex:int = hitIndex >> 1;
			var middleItem:SWFCacheItem = hits[middleIndex];
			middleItem.hitIndex = hitIndex;
			hits[hitIndex] = middleItem;

			hitIndex = middleIndex;

			item.key = key;
			item.clazz = clazz;
			item.size = size;
			item.hitIndex = hitIndex;
		}
		else
		{
			hitIndex = hits.length++;
			item = new SWFCacheItem(key, clazz, size, hitIndex);
		}

		hits[hitIndex] = item;
		data[key] = item;
	}
}
}