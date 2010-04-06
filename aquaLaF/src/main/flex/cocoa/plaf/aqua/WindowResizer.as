package cocoa.plaf.aqua
{
import flash.events.MouseEvent;

import mx.core.IUIComponent;

public class WindowResizer
{
	private var offsetX:Number;
	private var offsetY:Number;

	private var object:IUIComponent;

	public function resize(event:MouseEvent, object:IUIComponent):void
	{
		this.object = object;

		offsetX = event.stageX - object.width;
		offsetY = event.stageY - object.height;

		object.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		object.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}

	private function mouseMoveHandler(event:MouseEvent):void
	{
		object.width = Math.min(Math.max(Math.round(event.stageX - offsetX), object.minWidth), object.maxWidth);
		object.height = Math.min(Math.max(Math.round(event.stageY - offsetY), object.minHeight), object.maxHeight);
		event.updateAfterEvent();
	}

	private function mouseUpHandler(event:MouseEvent):void
	{
		object.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		object.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);

		object = null;
	}
}
}