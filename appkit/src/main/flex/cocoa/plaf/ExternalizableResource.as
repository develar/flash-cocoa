package cocoa.plaf
{
import flash.utils.ByteArray;

public interface ExternalizableResource
{
	function writeExternal(output:ByteArray):void;
	function readExternal(input:ByteArray):void;
}
}