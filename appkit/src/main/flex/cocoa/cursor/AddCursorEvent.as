package cocoa.cursor
{
import flash.events.Event;

import mx.managers.CursorManagerPriority;

public class AddCursorEvent extends Event
{
	public static const ADD:String = "addCursor";

	public function AddCursorEvent(cursorType:int, priority:int = CursorManagerPriority.MEDIUM)
	{
		_cursorType = cursorType;
		_priority = priority;

		super(ADD);
	}

	private var _cursorType:int;
	public function get cursorType():int
	{
		return _cursorType;
	}

	private var _priority:int;
	public function get priority():int
	{
		return _priority;
	}
}
}