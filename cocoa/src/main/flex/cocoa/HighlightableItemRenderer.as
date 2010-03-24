package cocoa
{
import spark.components.IItemRenderer;

public interface HighlightableItemRenderer extends IItemRenderer
{
	function set highlighted(value:Boolean):void;

	function get enabled():Boolean;
}
}