package cocoa
{
import flash.events.Event;

public class ComponentEvent extends Event
{
	public static const READY_TO_CREATE_SKIN:String = "readyToCreateSkin";

	public function ComponentEvent(type:String)
	{
		super(type);
	}
}
}