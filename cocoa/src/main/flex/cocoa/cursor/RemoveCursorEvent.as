package cocoa.cursor
{
import flash.events.Event;

public class RemoveCursorEvent extends Event
{
	public static const REMOVE:String = "removeCursor";

	public function RemoveCursorEvent(cursorType:int)
	{
		_cursorType = cursorType;

		super(REMOVE);
	}

	private var _cursorType:int;
	public function get cursorType():int
	{
		return _cursorType;
	}
}
}