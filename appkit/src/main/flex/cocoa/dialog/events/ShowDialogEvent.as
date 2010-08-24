package cocoa.dialog.events
{
import cocoa.Window;

import flash.events.Event;

public class ShowDialogEvent extends Event
{
	public static const SHOW_DIALOG:String = "showDialog";

	public function ShowDialogEvent(box:Window, modal:Boolean = true)
	{
		_box = box;
		_modal = modal;

		super(SHOW_DIALOG, true);
	}

	private var _box:Window;
	public function get box():Window
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