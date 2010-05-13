package cocoa
{
import cocoa.plaf.PushButtonSkin;

import flash.events.MouseEvent;

public class AbstractButton extends AbstractControl implements Cell
{
	protected var mySkin:PushButtonSkin;

	private var oldState:int = -1;

	public function get selected():Boolean
	{
		return state == CellState.ON;
	}
	public function set selected(value:Boolean):void
	{
		if (value && state != CellState.ON)
		{
			state = value ? CellState.ON : CellState.OFF;
		}
	}

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

	protected function get toggled():Boolean
	{
		return false;
	}

	private function stageMouseUpHandler(event:MouseEvent):void
	{
		mySkin.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

		mySkin.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		mySkin.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		
		if (event.target == mySkin)
		{
			// может быть уже отвалидировано в roll over/out
			if (toggled)
			{
				if (state == oldState)
				{
					state = oldState == CellState.OFF ? CellState.ON : CellState.OFF;
					event.updateAfterEvent();
				}
				else
				{
					// во fluent есть over — при установке state в mouseOverHandler mouseDown == true, а тут уже up — для button state разницы нет, а вот для скина поддерживающего over есть
					skin.invalidateDisplayList();
				}
			}
			else if (state == CellState.ON)
			{
				state = CellState.OFF;
				event.updateAfterEvent();
			}

			if (_action != null)
			{
				_action();
			}
		}

		oldState = -1;
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