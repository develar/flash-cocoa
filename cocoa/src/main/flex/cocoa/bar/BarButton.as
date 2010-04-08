package cocoa.bar
{
import flash.events.MouseEvent;

import spark.components.ButtonBarButton;

/**
 * Кнопка в панели не отвечает за MOUSE_DOWN и MOUSE_UP — выделение осуществляет менеджер
 */
public class BarButton extends ButtonBarButton
{
	override protected function addHandlers():void
	{
		addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler);
		addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler);
	}
}
}