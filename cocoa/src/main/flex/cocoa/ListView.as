package cocoa
{
import spark.components.List;

public class ListView extends List implements Viewable, Control
{
	protected var _action:Function;
	public function set action(value:Function):void
	{
		_action = value;
	}

	protected override function commitSelection(dispatchChangedEvents:Boolean = true):Boolean
	{
		var result:Boolean = super.commitSelection(dispatchChangedEvents);
		if (_action != null && result && dispatchChangedEvents)
		{
			_action();
		}

		return result;
	}

	public function get objectValue():Object
	{
		return selectedItem;
	}

	public function set objectValue(value:Object):void
	{
		selectedItem = value;
	}
}
}