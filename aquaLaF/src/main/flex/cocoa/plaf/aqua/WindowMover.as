package cocoa.plaf.aqua
{
import cocoa.Insets;

import flash.events.MouseEvent;
import flash.text.engine.TextLine;

import mx.core.IFlexDisplayObject;

/**
 * В отличие от flash native startDrag/stopDrag вешает mouse move на stage — в результате при выходе мыши за границы окна все продолжает работать.
 */
public class WindowMover
{
	private var offsetX:Number;
	private var offsetY:Number;

	private var object:IFlexDisplayObject;
	private var titleBarHeight:Number;

	private var contentInsets:Insets;

	private static const MIN_SIDE_VISIBLE_WIDTH:Number = 4;

	public function WindowMover(object:IFlexDisplayObject, titleBarHeight:Number, contentInsets:Insets)
	{
		this.object = object;
		this.titleBarHeight = titleBarHeight;
		this.contentInsets = contentInsets;

		object.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}

	private function mouseDownHandler(event:MouseEvent):void
	{
		var objectHeight:Number = object.height;
		var mouseY:Number = event.localY;
		var mouseX:Number = event.localX;
		if ((event.target != object && !(event.target is TextLine)) ||
			mouseY < 0 || mouseX < 0 || mouseX > object.width || mouseY > object.height || /* skip shadow */
			(mouseY > contentInsets.top && mouseY < (objectHeight - contentInsets.bottom)))
		{
			return;
		}

		offsetX = event.stageX - object.x;
		offsetY = event.stageY - object.y;

		object.cacheAsBitmap = true;
		object.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		object.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
	}

	private function mouseUpHandler(event:MouseEvent):void
	{
		object.cacheAsBitmap = false;
		object.stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		object.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);

		var maxY:Number = object.stage.stageHeight - titleBarHeight;
		if ((event.stageY - offsetY) > maxY)
		{
			object.y = maxY;
		}
	}

	private function mouseMoveHandler(event:MouseEvent):void
	{
		// округляем, так как скин окна может использовать битмапы, — лучше если координаты будут целыми
		var y:Number = Math.round(event.stageY - offsetY);
		if (y < 0)
		{
			y = 0;
		}

		var x:Number = Math.round(event.stageX - offsetX);
		var minX:Number = MIN_SIDE_VISIBLE_WIDTH - object.width;
		if (x < minX)
		{
			x = minX;
		}
		else
		{
			var maxX:Number = object.stage.stageWidth - MIN_SIDE_VISIBLE_WIDTH;
			if (x > maxX)
			{
				x = maxX;
			}
		}

		object.move(x, y);
		event.updateAfterEvent();
	}
}
}