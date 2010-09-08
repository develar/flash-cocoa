package cocoa.pane
{
import flash.events.Event;

import cocoa.lang.Enum;
import org.flyti.util.List;

public class RegisterPaneCollectionEvent extends Event
{
	public static const REGISTER_PANE_COLLECTION:String = "registerPaneCollection";
	
	public function RegisterPaneCollectionEvent(id:Enum, list:List)
	{
		_id = id;
		_list = list;

		super(REGISTER_PANE_COLLECTION);
	}

	private var _id:Enum;
	public function get id():Enum
	{
		return _id;
	}

	private var _list:List;
	public function get list():List
	{
		return _list;
	}
}
}