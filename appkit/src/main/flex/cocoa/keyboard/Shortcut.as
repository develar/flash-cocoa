package cocoa.keyboard
{
public final class Shortcut
{
	public static const ANY_PROFILE:uint = 0;
	
	public var profile:uint = ANY_PROFILE;

	public var command:Boolean = true;
	public var shift:Boolean = false;
	public var alt:Boolean = false;
	public var code:uint;
}
}