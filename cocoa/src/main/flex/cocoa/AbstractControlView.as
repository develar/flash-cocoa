package cocoa
{
public class AbstractControlView extends AbstractView
{
	protected var _action:Function;
	public function set action(value:Function):void
	{
		_action = value;
	}
}
}