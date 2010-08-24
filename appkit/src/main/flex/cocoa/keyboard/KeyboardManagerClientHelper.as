package cocoa.keyboard
{
public class KeyboardManagerClientHelper
{
	private var client:KeyboardManagerClient;

	public function KeyboardManagerClientHelper(client:KeyboardManagerClient)
	{
		this.client = client;
	}

	private var _shortcut:String;
	public function set shortcut(value:String):void
	{
		if (_shortcut != value)
		{
			var newTooltTip:String = removeShortcutFromToolTip(client.toolTip, _shortcut);
			_shortcut = value;
			client.toolTip = newTooltTip;
		}
	}

	public function adjustRawToolTip(value:String):String
	{
		if (_shortcut != null)
		{
			value += " (" + _shortcut + ")";
		}

		return value;
	}

	private function removeShortcutFromToolTip(toolTip:String, shortcut:String):String
	{
		if (shortcut != null && toolTip != null && toolTip.length > (shortcut.length + 3) && toolTip.slice(-(shortcut.length + 1), -1) == shortcut)
		{
			return toolTip.slice(0, -(shortcut.length + 3));
		}
		else
		{
			return toolTip;
		}
	}
}
}