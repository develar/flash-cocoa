package cocoa
{
public class AbstractControl extends AbstractComponent implements Control
{
	protected var _action:Function;
	public function set action(value:Function):void
	{
		_action = value;
	}
}
}