package cocoa.dialog.events
{
import flash.events.Event;

import org.flyti.view.View;

public class ShowDialogEvent extends Event
{
	public static const SHOW_DIALOG:String = "showDialog";

	public function ShowDialogEvent(box:View, modal:Boolean = true)
	{
		_box = box;
		_modal = modal;

		super(SHOW_DIALOG, true);
	}

	private var _box:View;
	public function get box():View
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