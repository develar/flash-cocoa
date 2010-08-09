package cocoa
{
import cocoa.plaf.LookAndFeel;

import flash.text.engine.ElementFormat;
import flash.utils.getDefinitionByName;

import mx.core.IFactory;

public class UIManager
{
	protected static var laf:LookAndFeel;

	public function setLookAndFeelByClassName(className:String):void
	{
		setLookAndFeelByClass(Class(getDefinitionByName(className)));
	}

	public function setLookAndFeelByClass(clazz:Class):void
	{
		lookAndFeel = new clazz();
	}

	public function set lookAndFeel(value:LookAndFeel):void
	{
		laf = value;
//		laf.initialize();
	}

	public function getBorder(key:String):Border
	{
		return laf.getBorder(key);
	}

	public function getIcon(key:String):Icon
	{
		return laf.getIcon(key);
	}

	public function getFont(key:String):ElementFormat
	{
		return laf.getFont(key);
	}

	public function getUI(key:String):Class
	{
		return laf.getClass(key);
	}
	
	public function getFactory(key:String):IFactory
	{
		return laf.getFactory(key);
	}
}
}