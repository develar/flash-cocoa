package cocoa
{
public class AbstractControlView extends AbstractComponent
{
	protected var _action:Function;
	public function set action(value:Function):void
	{
		_action = value;
	}
}
}