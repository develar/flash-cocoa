package org.flyti.lang
{
public class Enum
{
	public function Enum(name:String)
	{
		_name = name;
	}

	private var _name:String;
	public function get name():String
	{
		return _name;
	}
}
}