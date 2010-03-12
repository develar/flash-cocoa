package cocoa.plaf
{
import flash.display.DisplayObject;
import flash.geom.Point;

import mx.core.IFlexDisplayObject;
import mx.managers.PopUpManager;

public class PopUpAnchor
{
	protected static const sharedPoint:Point = new Point();

	protected var _popUp:IFlexDisplayObject;
	public function set popUp(value:IFlexDisplayObject):void
    {
        _popUp = value;
    }

	protected var _popUpParent:DisplayObject;
	public function set popUpParent(value:DisplayObject):void
    {
        _popUpParent = value;
    }

	public function set displayPopUp(value:Boolean):void
	{
		if (value)
		{
			PopUpManager.addPopUp(_popUp, _popUpParent, false);
			setPopUpPosition();
		}
		else
		{
			PopUpManager.removePopUp(_popUp);
		}
	}

	protected function setPopUpPosition():void
    {

	}
}
}