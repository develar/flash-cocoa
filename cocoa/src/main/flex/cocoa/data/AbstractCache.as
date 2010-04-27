package cocoa.data
{
import flash.utils.Dictionary;

internal class AbstractCache
{
	protected var currentSize:int;
	protected var maxSize:int;
	
	protected var data:Object = new Dictionary();
	
	public function contains(key:String):Boolean
	{
		return key in data;
	}
}
}