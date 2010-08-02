package cocoa.plaf.basic
{
import cocoa.Border;
import cocoa.Icon;
import cocoa.border.AbstractBitmapBorder;
import cocoa.border.OneBitmapBorder;
import cocoa.border.Scale1BitmapBorder;
import cocoa.border.Scale3EdgeHBitmapBorder;
import cocoa.border.Scale3HBitmapBorder;
import cocoa.border.Scale3VBitmapBorder;
import cocoa.border.Scale9BitmapBorder;
import cocoa.plaf.CursorData;
import cocoa.plaf.LookAndFeel;

import flash.text.engine.ElementFormat;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.formats.ITextLayoutFormat;

import mx.core.DeferredInstanceFromClass;
import mx.core.IFactory;

public class AbstractLookAndFeel implements LookAndFeel
{
	protected const data:Dictionary = new Dictionary();

	protected static function initAssets(data:Dictionary, assetsDataClass:Class):void
	{
		var assetsData:ByteArray = new assetsDataClass();
		assetsDataClass = null;

		var n:int = assetsData.readUnsignedByte();
		var border:AbstractBitmapBorder;
		for (var i:int = 0; i < n; i++)
		{
			const key:String = assetsData.readUTF();
			const typeMarker:int = assetsData.readUnsignedByte();
			switch (typeMarker)
			{
				case 0: border = new Scale3EdgeHBitmapBorder(); break;
				case 1: border = new Scale1BitmapBorder(); break;
				case 2: border = new Scale9BitmapBorder(); break;
				case 3: border = new OneBitmapBorder(); break;
				case 4: border = new Scale3HBitmapBorder(); break;
				case 5: border = new Scale3VBitmapBorder(); break;

				default: throw new Error("unknown type marker" + typeMarker);
			}
			border.readExternal(assetsData);
			data[key] = border;
		}

		var icon:BitmapIcon;
		while (assetsData.bytesAvailable > 0)
		{
			icon = new BitmapIcon();
			data[assetsData.readUTF()] = icon;
			icon.readExternal(assetsData);
		}
	}

	public final function get defaults():Dictionary
	{
		return data;
	}

	protected var _parent:LookAndFeel;
	public function set parent(value:LookAndFeel):void
	{
		_parent = value;
	}

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

	public function getObject(key:String):Object
	{
		var value:Object = data[key];
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
			return _parent.getObject(key);
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

	public function getTextFormat(key:String):ITextLayoutFormat
	{
		var value:ITextLayoutFormat = data[key];
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
			return _parent.getTextFormat(key);
		}
	}

	public function getSelectionFormat(key:String):SelectionFormat
	{
		var value:SelectionFormat = data[key];
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
			return _parent.getSelectionFormat(key);
		}
	}

	public function getClass(key:String):Class
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
			return _parent.getClass(key);
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

	public function getCursor(cursorType:int):CursorData
	{
		var value:CursorData = data[cursorType];
		if (value != null)
		{
			return value;
		}
		else if (_parent == null)
		{
			throw new ArgumentError("Unknown " + cursorType);
		}
		else
		{
			return _parent.getCursor(cursorType);
		}
	}

	public function getColors(key:String):Vector.<uint>
	{
		var value:Vector.<uint> = data[key];
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
			return _parent.getColors(key);
		}
	}
}
}