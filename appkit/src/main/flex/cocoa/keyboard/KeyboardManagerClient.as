package cocoa.keyboard
{
import flash.events.IEventDispatcher;

import mx.core.UIComponent;
import mx.managers.IToolTipManagerClient;

public interface KeyboardManagerClient extends IEventDispatcher, IToolTipManagerClient
{
	function set shortcut(value:String):void;

	function get skin():UIComponent;
}
}