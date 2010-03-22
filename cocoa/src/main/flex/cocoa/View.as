package cocoa
{
import flash.display.DisplayObject;

import mx.core.IUIComponent;

public interface View extends Viewable, IUIComponent
{
	/**
	 *  This method allows access to the Player's native implementation of addChild()
	 */
	function addDisplayObject(displayObject:DisplayObject, index:int = -1):void;
	/**
	 *  This method allows access to the Player's native implementation of removeChild()
	 */
	function removeDisplayObject(displayObject:DisplayObject):void;

	function get initialized():Boolean;
}
}