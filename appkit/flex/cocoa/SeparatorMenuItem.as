package cocoa
{
import flash.errors.IllegalOperationError;

internal final class SeparatorMenuItem extends MenuItem
{
	override public function get isSeparatorItem():Boolean
	{
		return true;
	}

	override public function get enabled():Boolean
	{
		return false;
	}

	override public function set enabled(value:Boolean):void
	{
		throw new IllegalOperationError();
	}
}
}