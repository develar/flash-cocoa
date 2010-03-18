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

	private var _parent:LookAndFeel;
	public function set parent(value:LookAndFeel):void
	{
		_parent = value;
	}

//	public function initialize():void
//	{
//		throw new Error("abstract");
//	}

	public function getBorder(key:String):Border
	{
		var value:Object = data[key];
		if (value != null)
		{
			return Border(value is Border ? value : DeferredInstanceFromClass(value).getInstance());
		}
		else if (_parent == null)
		{
			throw new ArgumentError("Unknown " + key);
		}
		else
		{
			return _parent.getBorder(key);
		}
	}

	public function getIcon(key:String):Icon
	{
		var value:Object = data[key];
		if (value != null)
		{
			return Icon(value is Icon ? value : DeferredInstanceFromClass(value).getInstance());
		}
		else if (_parent == null)
		{
			throw new ArgumentError("Unknown " + key);
		}
		else
		{
			return _parent.getIcon(key);
		}
	}

	public function getFont(key:String):ElementFormat
	{
		var value:ElementFormat = data[key];
		if (value != null)
		{
			return value;
		}
		else if (_parent == null)
		{
			throw new ArgumentError("Unknown " + key);
		}
		else
		{
			return _parent.getFont(key);
		}
	}

	public function getUI(key:String):Class
	{
		var value:Class = data[key];
		if (value != null)
		{
			return value;
		}
		else if (_parent == null)
		{
			throw new ArgumentError("Unknown " + key);
		}
		else
		{
			return _parent.getUI(key);
		}
	}

	public function getFactory(key:String):IFactory
	{
		var value:IFactory = data[key];
		if (value != null)
		{
			return value;
		}
		else if (_parent == null)
		{
			throw new ArgumentError("Unknown " + key);
		}
		else
		{
			return _parent.getFactory(key);
		}
	}

	public function getCursor(key:String):CursorData
	{
		var value:CursorData = data[key];
		if (value != null)
		{
			return value;
		}
		else if (_parent == null)
		{
			throw new ArgumentError("Unknown " + key);
		}
		else
		{
			return _parent.getCursor(key);
		}
	}
}
}