package cocoa.dialog.events
{
import cocoa.Component;

import flash.events.Event;

public class ShowDialogEvent extends Event
{
	public static const SHOW_DIALOG:String = "showDialog";

	public function ShowDialogEvent(box:Component, modal:Boolean = true)
	{
		_box = box;
		_modal = modal;

		super(SHOW_DIALOG, true);
	}

	private var _box:Component;
	public function get box():Component
	{
		return _box;
	}

	private var _modal:Boolean;
	public function get modal():Boolean
	{
		return _modal;
	}
}
}