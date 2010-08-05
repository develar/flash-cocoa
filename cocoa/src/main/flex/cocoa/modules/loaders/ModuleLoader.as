package cocoa.modules.loaders
{
import cocoa.modules.ModuleInfo;

import flash.events.IEventDispatcher;
import flash.system.ApplicationDomain;

public interface ModuleLoader extends IEventDispatcher
{
	function get applicationDomain():ApplicationDomain
	function get moduleInfo():ModuleInfo;

	function load():void;
}
}