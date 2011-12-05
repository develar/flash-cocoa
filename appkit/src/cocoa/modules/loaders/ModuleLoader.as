package cocoa.modules.loaders {
import cocoa.modules.ModuleInfo;

import flash.system.ApplicationDomain;

public interface ModuleLoader {
  function get applicationDomain():ApplicationDomain

  function get moduleInfo():ModuleInfo;

  function load():void;

  function set completeHandler(value:Function):void;

  function set errorHandler(value:Function):void;
}
}