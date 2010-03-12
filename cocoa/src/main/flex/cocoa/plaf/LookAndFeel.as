package cocoa.plaf
{
import cocoa.Border;
import cocoa.Icon;

import flash.text.engine.ElementFormat;
import flash.utils.Dictionary;

import mx.core.IFactory;

public interface LookAndFeel
{
	function initialize():void;
	
	function getBorder(key:String):Border;
	function getIcon(key:String):Icon;
	function getFont(key:String):ElementFormat;

	function getUI(key:String):Class;

	function getFactory(key:String):IFactory;
}
}