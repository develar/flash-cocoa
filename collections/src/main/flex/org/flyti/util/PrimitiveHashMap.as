package org.flyti.util
{
public class PrimitiveHashMap implements Map
{
	protected var storage:Object;

	public function PrimitiveHashMap(data:Object = null)
	{
		if (data == null)
		{
			storage = new Object();
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

	public function get empty():Boolean
	{
		return _size == 0;
	}

	protected var _size:int = 0;
	public function get size():int
	{
		return _size;
	}

	public function containsKey(key:Object):Boolean
	{
		return key in storage;
	}

	public function get(key:Object):Object
	{
		if (key in storage)
		{
			return storage[key];
		}
		else
		{
			throw new KeyNotPresentError(key);
		}
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

	public function remove(key:Object):Object
	{
		const value:Object = get(key);
		delete storage[key];
		_size--;

		return value;
	}

	/**
	 * У нас сейчас всего одна реализация интерфейса Map, поэтому putAll оптимизирован для PrimitiveHashMap
	 */
	public function putAll(map:Map):void
	{
		for (var key:Object in PrimitiveHashMap(map).storage)
		{
			put(key, map.get(key));
		}
	}

	public function removeAll(map:Map):void
	{
		for (var key:Object in PrimitiveHashMap(map).storage)
		{
			delete storage[key];
		}
		_size -= map.size;
	}

	public function get keySet():Vector.<Object>
	{
		var i:int = size;
		var result:Vector.<Object> = new Vector.<Object>(i, true);
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