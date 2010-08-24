package cocoa
{
/**
 * http://developer.apple.com/mac/library/documentation/cocoa/Conceptual/ControlCell/Concepts/CellStates.html#//apple_ref/doc/uid/20000069
 * http://developer.apple.com/mac/library/documentation/cocoa/reference/ApplicationKit/Classes/NSButton_Class/Reference/Reference.html#//apple_ref/occ/instm/NSButton/setState:
 */
public final class CellState
{
	/**
	 * normal or unpressed state
	 */
	public static const OFF:int = 0;

	/**
	 * alternate or pressed state
	 */
	public static const ON:int = 1;

	/**
	 * A mixed state is useful for a checkbox or radio button that reflects the status of a feature that’s true only for some items in your application or the current selection.
	 */
	public static const MIXED:int = 2;
}
}