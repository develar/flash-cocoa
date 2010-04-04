package cocoa.plaf.scrollbar
{
import cocoa.Border;

import flash.events.Event;
import flash.events.MouseEvent;

internal final class TrackOrThumbButton extends AbstractButton
{
	public function set border(value:Border):void
	{
		_border = value;
		minHeight = _border.layoutHeight;
	}

	override protected function addHandlers():void
	{
		addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler);
		addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
		addEventListener(MouseEvent.CLICK, mouseEventHandler);
	}

	override protected function mouseEventHandler(event:Event):void
	{
		var mouseEvent:MouseEvent = MouseEvent(event);
		if (!(mouseEvent.localX < 0 || mouseEvent.localY < 0 || mouseEvent.localX > width || mouseEvent.localY > height))
		{
			super.mouseEventHandler(event);
		}
	}
}
}