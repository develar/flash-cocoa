package cocoa.plaf.scrollbar
{
import flash.events.MouseEvent;

internal final class ArrowButton extends AbstractButton
{
	override protected function addHandlers():void
	{
		addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
		addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
		addEventListener(MouseEvent.CLICK, mouseEventHandler);
	}
}
}