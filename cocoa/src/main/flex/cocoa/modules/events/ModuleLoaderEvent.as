package cocoa.modules.events
{
import cocoa.modules.ModuleInfo;
import cocoa.modules.loaders.ModuleLoader;

import flash.display.LoaderInfo;

public class ModuleLoaderEvent extends LoaderEvent
{
	public function ModuleLoaderEvent(type:String, loader:ModuleLoader, info:LoaderInfo = null)
	{
		_loader = loader;
		
		super(type, info);
	}

	private var _loader:ModuleLoader;
	public function get loader():ModuleLoader
	{
		return _loader;
	}

	public function get moduleInfo():ModuleInfo
	{
		return loader.moduleInfo;
	}
}
}