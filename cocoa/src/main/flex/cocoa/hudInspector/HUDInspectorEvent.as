package cocoa.hudInspector
{
import cocoa.pane.PaneItem;

import flash.events.Event;

public class HUDInspectorEvent extends Event
{
	public static const REGISTER_HUD_INSPECTOR:String = "registerHUDInspector";

	public function HUDInspectorEvent(type:String, objectClass:Class, inspectorItem:PaneItem)
	{
		_objectClass = objectClass;
		_inspectorItem = inspectorItem;

		super(type);
	}

	private var _inspectorItem:PaneItem;
	public function get inspectorItem():PaneItem
	{
		return _inspectorItem;
	}

	private var _objectClass:Class;
	public function get objectClass():Class
	{
		return _objectClass;
	}
}
}