package cocoa.plaf
{
import cocoa.Border;
import cocoa.Icon;

import flash.text.engine.ElementFormat;
import flash.utils.Dictionary;

import mx.core.DeferredInstanceFromClass;
import mx.core.IFactory;

public class AbstractLookAndFeel implements LookAndFeel
{
	protected const data:Dictionary = new Dictionary();

	public function initialize():void
	{
		throw new Error("abstract");
	}

	public function getBorder(key:String):Border
	{
		var value:Object = data[key];
		return Border(value is Border ? value : DeferredInstanceFromClass(value).getInstance());
	}

	public function getIcon(key:String):Icon
	{
		var value:Object = data[key];
		return Icon(value is Icon ? value : DeferredInstanceFromClass(value).getInstance());
	}

	public function getFont(key:String):ElementFormat
	{
		return ElementFormat(data[key]);
	}

	public function getUI(key:String):Class
	{
		return Class(data[key]);
	}

	public function getFactory(key:String):IFactory
	{
		return IFactory(data[key]);
	}
}
}