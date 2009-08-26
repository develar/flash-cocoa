package org.flyti.util
{
import flash.utils.Dictionary;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

[RemoteClass]

[DefaultProperty("entrySet")]
public class HashMap implements IExternalizable, Map
{
	private var storage:Dictionary;

	public function HashMap(weakKeys:Boolean = false)
	{
		storage = new Dictionary(weakKeys);
	}

	public function get empty():Boolean
	{
		return _size == 0;
	}

	private var _size:int = 0;
	public function get size():int
	{
		return _size;
	}

	public function containsKey(key:Object):Boolean
	{
		return key in storage;
	}

	public function get(key:Object):*
	{
		const value:* = storage[key];
		if (value === undefined)
		{
			throw new KeyNotPresentError(key);
		}
		return value;
	}

	public function put(key:Object, value:Object):void
	{
		if (key == null)
		{
			throw new Error("key must be not null");
		}

		const presentKey:Boolean = containsKey(key);
		storage[key] = value;
		if (!presentKey)
		{
			_size++;
		}
	}

	public function remove(key:Object):*
	{
		const value:Object = get(key);
		delete storage[key];
		_size--;

		return value;
	}

	public function putAll(map:Map):void
	{
		for each (var key:Object in map.keySet)
		{
			put(key, map.get(key));
		}
	}

	public function removeAll(map:Map):void
	{
		for each (var key:Object in map.keySet)
		{
			delete storage[key];
		}
		_size -= map.size;
	}

	public function get keySet():Vector.<Object>
	{
		var i:int = _size;
		var result:Vector.<Object> = new Vector.<Object>(_size, true);
		for (var key:Object in storage)
		{
			result[--i] = key;
		}

		return result;
	}

	public function clear():void
	{
		_size = 0;
		for (var key:Object in storage)
		{
			delete storage[key];
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

	/**
	 * need for DefaultProperty and must use only for it — MXML compiler
	 */
	public function set entrySet(value:Vector.<MapEntry>):void
	{
		for each (var entry:MapEntry in value)
		{
			storage[entry.key] = entry.value;
		}

		_size = value.length;
	}
}
}