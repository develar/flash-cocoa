package cocoa.plaf
{
import cocoa.Border;
import cocoa.Icon;

import flash.text.engine.ElementFormat;
import flash.utils.Dictionary;

import mx.core.IFactory;

public interface LookAndFeel
{
	function get defaults():Dictionary;

	function set parent(value:LookAndFeel):void;

	function getBorder(key:String):Border;
	function getIcon(key:String):Icon;
	function getFont(key:String):ElementFormat;

	function getClass(key:String):Class;
	function getFactory(key:String):IFactory;

	function getCursor(cursorType:int):CursorData;

	function getColors(key:String):Vector.<uint>;
}
}