package cocoa
{
import flash.events.MouseEvent;

public class AbstractButton extends AbstractView
{
	private var state:int = ButtonState.off;

	public function AbstractButton()
	{
	}

	override protected function attachSkin():void
	{
		super.attachSkin();

		addHandlers();
	}

	protected function addHandlers():void
	{
		skin.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		skin.addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler);
		skin.addEventListener(MouseEvent.CLICK, mouseEventHandler);
	}

	private function mouseDownHandler(event:MouseEvent):void
	{
		skin.stage.addEventListener(MouseEvent.MOUSE_UP)
	}
}
}