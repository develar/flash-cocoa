package cocoa.modules.events
{
import flash.display.LoaderInfo;
import flash.events.Event;

public class LoaderEvent extends Event
{
	public static const ERROR:String = "fileLoadError";
	public static const COMPLETE:String = "fileLoadComplete";

	public function LoaderEvent(type:String, info:LoaderInfo)
	{
		_info = info;
		
		super(type);
	}

	private var _info:LoaderInfo;
	public function get info():LoaderInfo
	{
		return _info;
	}
}
}