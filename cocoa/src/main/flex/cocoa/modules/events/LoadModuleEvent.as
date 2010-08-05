package cocoa.modules.events
{
import cocoa.modules.ModuleInfo;

import flash.display.LoaderInfo;
import flash.events.Event;

public class LoadModuleEvent extends Event
{
	public static const INITIAL_MODULE_LOADED:String = "initialModuleLoaded";
	
	public static const INITIAL_STYLE_LOADED:String = "initialStyleLoaded";
	public static const INITIAL_LOCALE_LOADED:String = "initialLocaleLoaded";

	public static const MODULE_LOADED:String = "baseModuleLoaded";
	public static const STYLE_LOADED:String = "styleModuleLoaded";
	public static const RESOURCE_LOADED:String = "resourceModuleLoaded";

	public static const STYLE_PLUGIN_LOADED:String = "stylePluginLoaded";

	public static const LOAD_MODULE:String = "loadModule";
	public static const LOAD_STYLE:String = "loadStyle";
	public static const LOAD_LOCALE:String = "loadLocale";

	public function LoadModuleEvent(type:String, module:ModuleInfo, info:LoaderInfo = null)
	{
		_module = module;
		_info = info;
		
		super(type);
	}

	private var _info:LoaderInfo;
	public function get info():LoaderInfo
	{
		return _info;
	}

	private var _module:ModuleInfo;
	public function get module():ModuleInfo
	{
		return _module;
	}

}
}