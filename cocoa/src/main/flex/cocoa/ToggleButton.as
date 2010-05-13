package cocoa
{
public interface ToggleButton extends Cell, Control
{
	function get selected():Boolean;
	function set selected(value:Boolean):void;
}
}