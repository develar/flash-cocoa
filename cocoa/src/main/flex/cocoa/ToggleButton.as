package cocoa
{
import cocoa.keyboard.KeyboardManagerClient;
import cocoa.keyboard.KeyboardManagerClientHelper;

import spark.components.ToggleButton;

[Style(name="icon", type="Class")]
[Style(name="iconSelected", type="Class")]
public class ToggleButton extends spark.components.ToggleButton implements KeyboardManagerClient, Viewable
{
	public static const UNSELECTED_STATES:Vector.<String> = new <String>["up", "over", "down", "disabled"];
	public static const SELECTED_STATES:Vector.<String> = new <String>["upAndSelected", "overAndSelected", "downAndSelected", "disabledAndSelected"];

	private var shortcutHelper:KeyboardManagerClientHelper;
	
	private var prevButtonMode:Boolean = false;

	public function ToggleButton()
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

	override public function set enabled(value:Boolean):void
    {
		if (value != enabled)
		{
			super.enabled = value;

			if (value)
			{
				if (prevButtonMode)
				{
					prevButtonMode = false;
					buttonMode = true;
				}
			}
			else if (buttonMode)
			{
				prevButtonMode = true;
				buttonMode = false;
			}
		}
	}
}
}