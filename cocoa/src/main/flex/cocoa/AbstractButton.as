package cocoa
{
import cocoa.plaf.PushButtonSkin;

import flash.events.MouseEvent;

public class AbstractButton extends AbstractControl implements Cell
{
	protected var mySkin:PushButtonSkin;

	private var oldState:int = -1;

	public function get isMouseDown():Boolean
	{
		return oldState != -1;
	}

	override protected function skinAttachedHandler():void
	{
		super.skinAttachedHandler();

		mySkin = PushButtonSkin(skin);
		addHandlers();
	}

	protected function addHandlers():void
	{
		mySkin.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}

	private function mouseDownHandler(event:MouseEvent):void
	{
		oldState = state;

		mySkin.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

		mySkin.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		mySkin.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);

		mouseOverHandler(event);
	}

	private function stageMouseUpHandler(event:MouseEvent):void
	{
		oldState = -1;

		mySkin.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

		mySkin.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		mySkin.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		
		if (event.target == mySkin)
		{
			// может быть уже отвалидировано в roll over/out
			if (state == CellState.ON)
			{
				state = CellState.OFF;
				event.updateAfterEvent();
			}

			if (_action != null)
			{
				_action();
			}
		}
	}

	private function mouseOverHandler(event:MouseEvent):void
	{
		state = oldState == CellState.OFF ? CellState.ON : CellState.OFF;
		event.updateAfterEvent();
	}

	private function mouseOutHandler(event:MouseEvent):void
	{
		state = oldState;
		event.updateAfterEvent();
	}
}
}