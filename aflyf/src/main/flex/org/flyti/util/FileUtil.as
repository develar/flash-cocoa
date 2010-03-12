package org.flyti.util
{
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

public final class FileUtil
{
	public static const SEPARATOR:String = "/";

	private static const OPEN_MACRO:String = "{";
	private static const CLOSE_MACRO:String = "}";

	public static function writeBytes(filename:String, bytes:ByteArray):void
	{
		var fileStream:FileStream = new FileStream();
		fileStream.open(new File(filename), FileMode.WRITE);
		fileStream.writeBytes(bytes);
		fileStream.close();
	}

	public static function readBytes(filename:String):ByteArray
	{
		var fileStream:FileStream = new FileStream();
		fileStream.open(new File(filename), FileMode.READ);
		var bytes:ByteArray = new ByteArray();
		fileStream.readBytes(bytes);
		fileStream.close();
		return bytes;
	}

	public static function writeString(filename:String, string:String):void
	{
		var fileStream:FileStream = new FileStream();
		fileStream.open(new File(filename), FileMode.WRITE);
		fileStream.writeUTFBytes(string);
		fileStream.close();
	}

	public static function getCanonicalPath(path:String):String
	{
		if (StringUtil.startsWith(path, "file://"))
		{
			path = path.substr(7);
		}

		if (StringUtil.startsWith(path, OPEN_MACRO))
		{
			var i:int = 1;
			var character:String;
			var propertyName:String = "";
			while ((character = path.charAt(i++)) != CLOSE_MACRO)
			{
				if (character == "")
				{
					throw new Error("unclosed macros");
				}
				propertyName += character;
			}
			path = File(File[propertyName]).nativePath + File.separator + path.substr(i);
		}
		else if (!StringUtil.startsWith(path, SEPARATOR))
		{
			path = File.applicationDirectory.nativePath + File.separator + path;
		}

		return path;
	}
}
}