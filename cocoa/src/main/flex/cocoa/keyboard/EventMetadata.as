package cocoa.keyboard
{
import flash.events.Event;
import flash.utils.Dictionary;

public final class EventMetadata
{
	private static const instances:Dictionary = new Dictionary();

	public var clazz:Class;
	public var type:String;

	public function EventMetadata(clazz:Class = null, type:String = null)
	{
		this.clazz = clazz;
		this.type = type;

		instances[type] = this;
	}

	public function create():Event
	{
		return new clazz(type);
	}

	public static function create(clazz:Class, type:String):EventMetadata
	{
		if (type in instances)
		{
			return instances[type];
		}
		else
		{
			return new EventMetadata(clazz, type);
		}
	}
}
}