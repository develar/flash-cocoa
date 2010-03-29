package cocoa
{
public class AbstractControl extends AbstractComponent implements Control
{
	protected var _action:Function;
	public function set action(value:Function):void
	{
		_action = value;
	}

	public function get objectValue():Object
	{
		throw new Error("abstract");
	}

	public function set objectValue(value:Object):void
	{
		throw new Error("abstract");
	}
}
}