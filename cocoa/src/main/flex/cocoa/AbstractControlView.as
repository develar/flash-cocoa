package cocoa
{
public class AbstractControlView extends AbstractView
{
	protected var _actionHandler:Function;
	public function set actionHandler(value:Function):void
	{
		_actionHandler = value;
	}
}
}