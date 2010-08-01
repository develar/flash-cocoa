package cocoa.plaf
{
import cocoa.plaf.basic.BottomBarStyle;

public interface DialogSkin extends WindowSkin
{
	function set bottomBarStyle(value:BottomBarStyle):void;

	function set useWindowGap(value:Boolean):void;
}
}