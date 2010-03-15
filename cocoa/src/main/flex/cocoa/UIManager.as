package cocoa
{
import cocoa.plaf.LookAndFeel;

import flash.text.engine.ElementFormat;
import flash.utils.getDefinitionByName;

import mx.core.IFactory;

public class UIManager
{
	protected static var laf:LookAndFeel;

	public static function setLookAndFeelByClassName(className:String):void
	{
		setLookAndFeelByClass(Class(getDefinitionByName(className)));
	}

	public static function setLookAndFeelByClass(clazz:Class):void
	{
		lookAndFeel = new clazz();
	}

	public static function set lookAndFeel(value:LookAndFeel):void
	{
		laf = value;
		laf.initialize();
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