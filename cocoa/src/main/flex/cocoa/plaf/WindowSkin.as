package cocoa.plaf
{
import mx.core.UIComponent;

public interface WindowSkin
{
	function set title(value:String):void
	function set contentElement(value:UIComponent):void
	function set bottomBarStyle(value:BottomBarStyle):void
}
}