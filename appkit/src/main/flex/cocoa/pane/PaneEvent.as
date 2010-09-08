package cocoa.pane
{
import flash.events.Event;

import cocoa.lang.Enum;

public class PaneEvent extends Event
{
	public static const ADD_PANE:String = "addPane";

	public function PaneEvent(id:Enum, item:PaneItem)
	{
		_id = id;
		_item = item;
		
		super(ADD_PANE);
	}

	private var _id:Enum;
	public function get id():Enum
	{
		return _id;
	}

	private var _item:PaneItem;
	public function get item():PaneItem
	{
		return _item;
	}
}
}