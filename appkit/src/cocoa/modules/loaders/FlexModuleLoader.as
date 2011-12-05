package cocoa.modules.loaders {
import cocoa.modules.ModuleInfo;

import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.system.ApplicationDomain;

import mx.core.IFlexModuleFactory;
import mx.core.Singleton;
import mx.events.ModuleEvent;
import mx.modules.IModuleInfo;
import mx.modules.ModuleManager;

public class FlexModuleLoader extends SWFModuleLoader {
  protected var loadEventDispatcher:IEventDispatcher;

  public function FlexModuleLoader(moduleInfo:ModuleInfo, rootURI:String, applicationDomain:ApplicationDomain = null) {
    super(moduleInfo, rootURI, applicationDomain);
  }

  override public function load():void {
    adjustURI();
    var info:IModuleInfo = ModuleManager.getModule(_moduleInfo.uri);
    loadEventDispatcher = info;
    loadEventDispatcher.addEventListener(ModuleEvent.ERROR, loadErrorHandler);
    loadEventDispatcher.addEventListener(ModuleEvent.READY, loadCompleteHandler);

    loadEventDispatcher.addEventListener(ModuleEvent.SETUP, setupHandler);
    info.load(applicationDomain);
  }

  private function setupHandler(event:ModuleEvent):void {
    var factory:IFlexModuleFactory = event.module.factory;
    factory.registerImplementation("mx.styles::IStyleManager2", Singleton.getInstance("mx.styles::IStyleManager2"));
  }

  override protected function clear(event:Event):void {
    loadEventDispatcher.removeEventListener(ModuleEvent.ERROR, loadErrorHandler);
    loadEventDispatcher.removeEventListener(ModuleEvent.READY, loadCompleteHandler);

    loadEventDispatcher.removeEventListener(ModuleEvent.SETUP, setupHandler);
    loadEventDispatcher = null;
  }
}
}