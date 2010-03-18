package cocoa
{
import cocoa.plaf.PushButtonSkin;

import flash.events.MouseEvent;

public class AbstractButton extends AbstractControl
{
	protected var mySkin:PushButtonSkin;
	
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
//		trace(event);
		mySkin.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

		mySkin.addEventListener(MouseEvent.MOUSE_OVER, adjustState);
		mySkin.addEventListener(MouseEvent.MOUSE_OUT, adjustState);

		adjustState(event);
	}

	private function stageMouseUpHandler(event:MouseEvent):void
	{
//		trace(event);
		mySkin.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

		mySkin.removeEventListener(MouseEvent.MOUSE_OVER, adjustState);
		mySkin.removeEventListener(MouseEvent.MOUSE_OUT, adjustState);
		
		if (event.target == mySkin)
		{
			// может быть уже отвалидировано в roll over/out
			if (_state == ButtonState.on)
			{
				_state = ButtonState.off;
				mySkin.invalidateDisplayList();
				event.updateAfterEvent();
			}

			if (_action != null)
			{
				_action();
			}
		}
	}

	private function adjustState(event:MouseEvent):void
	{
		_state = _state == ButtonState.off ? ButtonState.on : ButtonState.off;
		mySkin.invalidateDisplayList();
		event.updateAfterEvent();
	}
}
}