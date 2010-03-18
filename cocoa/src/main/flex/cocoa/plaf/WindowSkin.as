package cocoa.plaf
{
import cocoa.View;

public interface WindowSkin extends Skin
{
	function set title(value:String):void;
	function set contentView(value:View):void;
	function set bottomBarStyle(value:BottomBarStyle):void;
}
}