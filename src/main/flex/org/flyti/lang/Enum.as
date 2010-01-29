package org.flyti.lang
{
public class Enum
{
	public function Enum(name:String, ordinal:int = -1)
	{
		_name = name;
		_ordinal = ordinal;
	}

	protected var _name:String;
	public function get name():String
	{
		return _name;
	}

	private var _ordinal:int;
	public function get ordinal():int
	{
		return _ordinal;
	}

	public function toString():String
	{
		return _name;
	}
}
}