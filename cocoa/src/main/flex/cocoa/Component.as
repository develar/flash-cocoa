package cocoa
{
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

public interface Component
{
	function get stylePrefix():String;
	function get skin():Skin;
	
	function set enabled(value:Boolean):void;
	
	function createView(laf:LookAndFeel):Skin;

	function uiPartAdded(id:String, instance:Object):void;
	
	function commitProperties():void;
}
}