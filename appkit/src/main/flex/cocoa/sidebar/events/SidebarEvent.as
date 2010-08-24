package cocoa.sidebar.events
{
import flash.events.Event;

public class SidebarEvent extends Event
{
	public static const HIDE_PANE:String = "hideSidebarPane";
	public static const HIDE_SIDE:String = "hideSidebar";

	public function SidebarEvent(type:String)
	{
		super(type);
	}
}
}