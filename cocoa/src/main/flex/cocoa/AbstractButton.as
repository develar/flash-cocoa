package cocoa
{
import cocoa.plaf.PushButtonSkin;

import flash.events.MouseEvent;

public class AbstractButton extends AbstractControlView
{
	protected var mySkin:PushButtonSkin;
	
	private var _state:int = ButtonState.off;
	public function get state():int
	{
		return _state;
	}

	override protected function attachSkin():void
	{
		super.attachSkin();

		mySkin = PushButtonSkin(skin);
		addHandlers();
	}

	protected function addHandlers():void
	{
		mySkin.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}

	private function mouseDownHandler(event:MouseEvent):void
	{
		mySkin.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

		mySkin.addEventListener(MouseEvent.MOUSE_OVER, mouseOverOrOutHandler);
		mySkin.addEventListener(MouseEvent.MOUSE_OUT, mouseOverOrOutHandler);

		adjustState(event);
	}

	private function stageMouseUpHandler(event:MouseEvent):void
	{
		mySkin.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

		mySkin.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverOrOutHandler);
		mySkin.removeEventListener(MouseEvent.MOUSE_OUT, mouseOverOrOutHandler);
		
		if (event.target == mySkin)
		{
			adjustState(event);
			if (_actionHandler != null)
			{
				_actionHandler();
			}
		}
	}

	private function mouseOverOrOutHandler(event:MouseEvent):void
	{
		if (!(event.localX == -1 && event.localY == -1 && event.stageX == -1))
		{
			adjustState(event);
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