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

	override public function getStyle(styleProp:String):*
	{
		switch (styleProp)
		{
			case "repeatDelay": return 500;
			case "repeatInterval": return 35;
		}

		return undefined;
	}
}
}