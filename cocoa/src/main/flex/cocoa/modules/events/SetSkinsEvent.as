package cocoa.modules.events
{
import cocoa.modules.ModuleInfo;

import flash.events.Event;

public class SetSkinsEvent extends Event
{
	public static const SET_SKINS:String = "setSkins";

	public function SetSkinsEvent(list:Vector.<ModuleInfo>):void
	{
		_list = list;

		super(SET_SKINS);
	}

	private var _list:Vector.<ModuleInfo>;
	public function get list():Vector.<ModuleInfo>
	{
		return _list;
	}
}
}