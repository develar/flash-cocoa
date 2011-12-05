package cocoa.plaf
{
public class CursorData
{
	public function CursorData(clazz:Class, x:Number = -10, y:Number = -10)
	{
		_clazz = clazz;
		_x = x;
		_y = y;
	}

	private var _clazz:Class;
	public function get clazz():Class
	{
		return _clazz;
	}

	private var _x:Number;
	public function get x():Number
	{
		return _x;
	}

	private var _y:Number;
	public function get y():Number
	{
		return _y;
	}
}
}