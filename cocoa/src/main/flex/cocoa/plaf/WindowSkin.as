package cocoa.plaf
{
import cocoa.Toolbar;
import cocoa.View;

public interface WindowSkin extends Skin
{
	function set title(value:String):void;

	function set toolbar(value:Toolbar):void;
	function set contentView(value:View):void;
}
}