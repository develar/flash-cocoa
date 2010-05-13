package cocoa
{
public class TogglePushButton extends PushButton implements ToggleButton
{
	override protected function get toggled():Boolean
	{
		return true;
	}
}
}