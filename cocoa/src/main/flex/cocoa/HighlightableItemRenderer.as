package cocoa
{
import flash.display.Stage;

import spark.components.IItemRenderer;

public interface HighlightableItemRenderer extends IItemRenderer
{
	function set highlighted(value:Boolean):void;

	function get enabled():Boolean;

	function get stage():Stage;
}
}