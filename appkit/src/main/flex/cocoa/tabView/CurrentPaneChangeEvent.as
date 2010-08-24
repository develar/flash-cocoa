package cocoa.tabView
{
import cocoa.pane.PaneItem;

import flash.events.Event;

public class CurrentPaneChangeEvent extends Event
{
	public static const CHANGING:String = "currentPaneChanging";
	public static const CHANGED:String = "currentPaneChanged";

	public function CurrentPaneChangeEvent(type:String, oldItem:PaneItem, newItem:PaneItem)
	{
		_oldItem = oldItem;
		_newItem = newItem;

		super(type);
	}

	private var _oldItem:PaneItem;
	public function get oldItem():PaneItem
	{
		return _oldItem;
	}

	private var _newItem:PaneItem;
	public function get newItem():PaneItem
	{
		return _newItem;
	}
}
}