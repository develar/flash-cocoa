package cocoa.modules.events
{
import cocoa.modules.ModuleInfo;

import flash.events.Event;

public class SetLocalesEvent extends Event
{
	public static const TYPE:String = "setLocales";

	public function SetLocalesEvent(list:Vector.<ModuleInfo>):void
	{
		_list = list;

		super(TYPE);
	}

	private var _list:Vector.<ModuleInfo>;
	public function get list():Vector.<ModuleInfo>
	{
		return _list;
	}
}
}