package cocoa
{
import cocoa.keyboard.KeyboardManagerClient;
import cocoa.keyboard.KeyboardManagerClientHelper;

import spark.components.CheckBox;

public class CheckBox extends spark.components.CheckBox implements KeyboardManagerClient
{
	private var shortcutHelper:KeyboardManagerClientHelper;

	public function CheckBox()
	{
		shortcutHelper = new KeyboardManagerClientHelper(this);

		super();
	}

	public function set shortcut(value:String):void
	{
		shortcutHelper.shortcut = value;
	}

	override public function set toolTip(value:String):void
	{
		super.toolTip = shortcutHelper.adjustRawToolTip(value);
	}
}
}