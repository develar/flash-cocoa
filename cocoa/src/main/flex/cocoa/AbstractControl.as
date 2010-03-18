package cocoa
{
public class AbstractControl extends AbstractComponent
{
	protected var _action:Function;
	public function set action(value:Function):void
	{
		_action = value;
	}
}
}