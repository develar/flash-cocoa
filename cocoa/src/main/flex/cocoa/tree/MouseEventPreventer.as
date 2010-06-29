package cocoa.tree
{
import flash.events.MouseEvent;

public interface MouseEventPreventer
{
	function preventMouseDown(event:MouseEvent, dispatchOpenEvent:Boolean = true):Boolean
}
}