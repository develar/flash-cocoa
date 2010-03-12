package org.flyti.filesystem
{
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;

/**
 * Из-за listDirectory (этот метод возвращает массив объектов типа flash.filesystem.File и привести к типу org.flyti.flyf.filesystem.File невозможно) мы не можем просто наследовать от flash.filesystem.File, поэтому мы создаем переменную file и в ней храним экземпляр объекта
 */
public class FileWrapper
{
	private var _file:File;
	public function get file():File
	{
		return _file;
	}

	private var _name:String;
	public function get name():String
	{
		if (_name == null)
		{
			_name = file.isDirectory || file.type == null ? baseName : file.name.substr(0, file.name.length - file.type.length);
		}
		return _name;
	}

	public function get baseName():String
	{
		return file.name;
	}

	public function FileWrapper(...path):void
	{
		if (path.length > 0)
		{
			if (path[0] is File)
			{
				_file = path[0];
			}
			else
			{
				_file = new File(path.join(File.separator));
			}
		}
		else
		{
			_file = new File();
		}
	}

	public function get contents():*
	{
		if (file.isDirectory)
		{
			var list:Array = file.getDirectoryListing();
			for (var i:String in list)
			{
				if (list[i].isHidden)
				{
					list.splice(i, 1);
				}
				else
				{
					list[i] = new FileWrapper(list[i]);
				}
			}
			return list;
		}
		else
		{
			return readString();
		}
	}

	public function set contents(contents:Object):void
	{
		var fileStream:FileStream = new FileStream();
		fileStream.open(file, FileMode.WRITE);

		if (contents is String)
		{
			fileStream.writeUTFBytes(String(contents));
		}
		else
		{
			fileStream.writeObject(contents);
		}

		fileStream.close();
	}

	public function read():Object
	{
		var fileStream:FileStream = new FileStream();
		fileStream.open(file, FileMode.READ);
		var result:Object = fileStream.readObject();
		fileStream.close();
		return result;
	}

	public function readString():String
	{
		var fileStream:FileStream = new FileStream();
		fileStream.open(file, FileMode.READ);
		var contents:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
		fileStream.close();
		return contents;
	}

	public function readXML():XML
	{
		return XML(readString());
	}

	public function writeXML(xml:XML):void
	{
		contents = xml.toXMLString();
	}
}
}