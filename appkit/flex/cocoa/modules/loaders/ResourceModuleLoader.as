package cocoa.modules.loaders {
import cocoa.modules.ModuleInfo;

import flash.events.Event;
import flash.system.ApplicationDomain;

import mx.events.ResourceEvent;

import cocoa.resources.ResourceManager;

public class ResourceModuleLoader extends FlexModuleLoader {
  private var update:Boolean;

  public function ResourceModuleLoader(moduleInfo:ModuleInfo, rootURI:String, applicationDomain:ApplicationDomain = null, update:Boolean = true) {
    this.update = update;

    super(moduleInfo, rootURI, applicationDomain);
  }

  override protected function get loadErrorMessage():String {
    return "errorLoadResourceModule";
  }

  override public function load():void {
    adjustURI();
    loadEventDispatcher = ResourceManager.instance.loadResourceModule(_moduleInfo.uri, update);
    loadEventDispatcher.addEventListener(ResourceEvent.ERROR, loadErrorHandler);
    loadEventDispatcher.addEventListener(ResourceEvent.COMPLETE, loadCompleteHandler);
  }

  override protected function clear(event:Event):void {
    loadEventDispatcher.removeEventListener(ResourceEvent.ERROR, loadErrorHandler);
    loadEventDispatcher.removeEventListener(ResourceEvent.COMPLETE, loadCompleteHandler);
    loadEventDispatcher = null;
  }
}
}