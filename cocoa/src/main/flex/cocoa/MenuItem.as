package cocoa
{
public class MenuItem
{
	public static function createSeparatorItem():MenuItem
	{
		return new SeparatorMenuItem();
	}

	public function get isSeparatorItem():Boolean
	{
		return false;
	}

	private var _enabled:Boolean = true;
	public function get enabled():Boolean
	{
		return _enabled;
	}
	public function set enabled(value:Boolean):void
	{
		_enabled = value;
	}
}
}