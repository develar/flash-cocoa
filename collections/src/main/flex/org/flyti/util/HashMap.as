package org.flyti.util
{
import flash.utils.Dictionary;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

[RemoteClass]
[DefaultProperty("entrySet")]
public class HashMap extends PrimitiveHashMap implements IExternalizable
{
	public function HashMap(weakKeys:Boolean = false, data:Object = null)
	{
		if (data == null)
		{
			storage = new Dictionary(weakKeys);
		}
		else
		{
			storage = data;
			for (var key:String in data)
			{
				_size++;
			}
		}
	}

	public function readExternal(input:IDataInput):void
	{
		storage = input.readObject();
	}

	public function writeExternal(output:IDataOutput):void
	{
		output.writeObject(storage);
	}
}
}