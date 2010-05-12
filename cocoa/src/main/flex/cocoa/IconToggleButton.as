package cocoa
{
public class IconToggleButton extends IconButton
{
	public function IconToggleButton()
	{
	}

	public function get selected():Boolean
	{
		return state == CellState.ON; 
	}

	override protected function get toggled():Boolean
	{
		return true;
	}
}
}