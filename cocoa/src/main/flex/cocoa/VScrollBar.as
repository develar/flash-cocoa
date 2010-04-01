package cocoa
{
import spark.components.VScrollBar;

public class VScrollBar extends spark.components.VScrollBar
{
	public function uiPartAdded(id:String, instance:Object):void
	{
		this[id] = instance;
		partAdded(id, instance);
	}
}
}