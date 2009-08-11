package org.flyti.util
{
public class MapEntry
{
	public function MapEntry(key:Object, value:Object)
	{
		_key = key;
		_value = value;
	}

	private var _key:Object;
	public function get key():Object
	{
		return _key;
	}

	private var _value:Object;
	public function get value():Object
	{
		return _value;
	}
}
}