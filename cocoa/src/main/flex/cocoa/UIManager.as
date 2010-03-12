package cocoa
{
import cocoa.plaf.LookAndFeel;

import flash.text.engine.ElementFormat;

import mx.core.IFactory;

public class UIManager
{
	protected static var laf:LookAndFeel;

	public static function set lookAndFeel(value:LookAndFeel):void
	{
		laf.initialize();
		laf = value;
	}

	public static function getBorder(key:String):Border
	{
		return laf.getBorder(key);
	}

	public static function getIcon(key:String):Icon
	{
		return laf.getIcon(key);
	}

	public static function getFont(key:String):ElementFormat
	{
		return laf.getFont(key);
	}

	public static function getUI(key:String):Class
	{
		return laf.getUI(key);
	}
	
	public static function getFactory(key:String):IFactory
	{
		return laf.getFactory(key);
	}
}
}