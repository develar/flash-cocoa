package cocoa
{
import cocoa.plaf.PushButtonSkin;

import flash.events.MouseEvent;

public class AbstractButton extends AbstractControl
{
	protected var mySkin:PushButtonSkin;

	private var oldState:int;
	
	private var _state:int = ButtonState.off;
	public function get state():int
	{
		return _state;
	}

	override protected function viewAttachedHandler():void
	{
		super.viewAttachedHandler();

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
		mySkin.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

		mySkin.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		mySkin.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
		
		if (event.target == mySkin)
		{
			// может быть уже отвалидировано в roll over/out
			if (_state == ButtonState.on)
			{
				_state = ButtonState.off;
				adjustState(event);
			}

			if (_action != null)
			{
				_action();
			}
		}
	}

	private function mouseOverHandler(event:MouseEvent):void
	{
		_state = oldState == ButtonState.off ? ButtonState.on : ButtonState.off;
		adjustState(event);
	}

	private function mouseOutHandler(event:MouseEvent):void
	{
		_state = oldState;
		adjustState(event);
	}

	private function adjustState(event:MouseEvent):void
	{
		mySkin.invalidateDisplayList();
		event.updateAfterEvent();
	}
}
}