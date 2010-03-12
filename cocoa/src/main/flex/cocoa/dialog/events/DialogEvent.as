package cocoa.dialog.events
{
import flash.events.Event;

public class DialogEvent extends Event
{
	public static const OK:String = "ok";
	public static const CANCEL:String = "cancel";

	public static const CLOSING:String = "closing";

	public function DialogEvent(type:String)
	{
		super(type);
	}
}
}