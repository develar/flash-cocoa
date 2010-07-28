package cocoa
{
import flash.events.Event;
import flash.events.MouseEvent;

public class AbstractButton extends AbstractControl implements Cell
{
	private var oldState:int = -1;

	override public function get objectValue():Object
	{
		return title;
	}

	[Bindable(event="selectedChanged")]
	public function get selected():Boolean
	{
		return state == CellState.ON;
	}

	public function set selected(value:Boolean):void
	{
		if (value != selected)
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

		addHandlers();
	}

	protected function addHandlers():void
	{
		skin.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}

	private function mouseDownHandler(event:MouseEvent):void
	{
		oldState = state;

		skin.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

		skin.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		skin.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);

		mouseOverHandler(event);
	}

	protected function get toggled():Boolean
	{
		return false;
	}

	private function stageMouseUpHandler(event:MouseEvent):void
	{
		skin.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

		skin.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		skin.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);

		if (event.target == skin)
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

			if (hasEventListener("selectedChanged"))
			{
				dispatchEvent(new Event("selectedChanged"));
			}

			if (_action != null)
			{
				_actionRequireTarget ?_action(this) : _action();
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

	override public function set state(value:int):void
	{
		super.state = value;
		if (oldState == -1 && hasEventListener("selectedChanged"))
		{
			dispatchEvent(new Event("selectedChanged"));
		}
	}
}
}