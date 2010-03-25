package cocoa
{
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

import flash.events.IEventDispatcher;

public interface Component extends Viewable, IEventDispatcher
{
	function get lafPrefix():String;
	function get skin():Skin;

	function set skinClass(value:Class):void;
	
	function set enabled(value:Boolean):void;

	function get hidden():Boolean;
	function set hidden(value:Boolean):void;
	
	function createView(laf:LookAndFeel):Skin;

	function uiPartAdded(id:String, instance:Object):void;
	
	function commitProperties():void;
}
}