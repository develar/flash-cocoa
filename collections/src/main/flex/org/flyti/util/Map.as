package org.flyti.util
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Dictionary;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

[RemoteClass]
public class Map implements IEventDispatcher, IExternalizable
{
	private var storage:Dictionary;

	private var keyListenable:Boolean;
	private var dispatcher:EventDispatcher;

	public function Map(weakKeys:Boolean = false, keyListenable:Boolean = false)
	{
		this.keyListenable = keyListenable;

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
			throw new Error("key is not present");
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
			if (keyListenable)
			{
				//IEventDispatcher(key).dispatchEvent(new MapKeyEvent(MapKeyEvent.PUT, this, value));
			}
			else if (dispatcher != null)
			{
				//dispatchEvent(new MapEntryEvent(MapEntryEvent.PUT, new MapEntry(key, value)));
			}
		}
	}

	public function remove(key:Object):*
	{
		const value:* = storage[key];
		delete storage[key];
		_size--;

		if (keyListenable)
		{
			//IEventDispatcher(key).dispatchEvent(new MapKeyEvent(MapKeyEvent.REMOVE, this, value));
		}
		else if (dispatcher != null)
		{
			//dispatchEvent(new MapEntryEvent(MapEntryEvent.REMOVE, new MapEntry(key, value)));
		}

		return value;
	}

	public function putAll(map:Map):void
	{
		for each (var key:Object in map.keySet)
		{
			put(key, map.get(key));
		}
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

	public function dispatchEvent(event:Event):Boolean
	{
		if (dispatcher == null)
		{
			return true;
		}
		else
		{
			return dispatcher.dispatchEvent(event);
		}
	}

	public function hasEventListener(type:String):Boolean
	{
		if (dispatcher == null)
		{
			return false;
		}
		else
		{
			return dispatcher.hasEventListener(type);
		}
	}

	public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
	{
		if (dispatcher == null)
		{
			dispatcher = new EventDispatcher(this);
		}
		dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
	{
		if (dispatcher != null)
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
	}

	public function willTrigger(type:String):Boolean
	{
		if (dispatcher == null)
		{
			return false;
		}
		else
		{
			return dispatcher.willTrigger(type);
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