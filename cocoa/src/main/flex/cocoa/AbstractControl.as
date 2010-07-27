package cocoa
{
public class AbstractControl extends AbstractComponent implements Control
{
	protected var _action:Function;
	public function set action(value:Function):void
	{
		_action = value;
	}

	protected var _actionRequireTarget:Boolean;
	public function set actionRequireTarget(value:Boolean):void
	{
		_actionRequireTarget = value;
	}

	private var _state:int = CellState.OFF;
	public final function get state():int
	{
		return _state;
	}
	public function set state(value:int):void
	{
		_state = value;
		if (skin != null)
		{
			skin.invalidateDisplayList();
		}
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