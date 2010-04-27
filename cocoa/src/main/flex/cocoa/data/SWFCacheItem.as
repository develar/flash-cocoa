package cocoa.data
{
internal final class SWFCacheItem extends AbstractCacheItem
{
	public var clazz:Class;

	public function SWFCacheItem(key:String, clazz:Class, size:int, hitIndex:int)
	{
		this.key = key;
		this.clazz = clazz;
		this.size = size;
		this.hitIndex = hitIndex;
	}
}
}