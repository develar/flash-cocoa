package cocoa
{
import flash.display.Graphics;

import mx.core.UIComponent;

public interface Icon
{
	function get iconWidth():Number;
	function get iconHeight():Number;

	function draw(object:UIComponent, g:Graphics, x:Number, y:Number):void;
}
}