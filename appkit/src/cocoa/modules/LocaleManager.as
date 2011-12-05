package cocoa.modules {
import cocoa.modules.events.LoadModuleEvent;
import cocoa.modules.loaders.FlexModuleLoader;
import cocoa.modules.loaders.ModuleLoader;
import cocoa.modules.loaders.ResourceModuleLoader;
import cocoa.resources.ResourceManager;

import flash.display.LoaderInfo;

public class LocaleManager extends ModuleManager {
  override protected function get initialModuleLoadedEventType():String {
    return LoadModuleEvent.INITIAL_LOCALE_LOADED;
  }

  override protected function get moduleLoadedEventType():String {
    return LoadModuleEvent.RESOURCE_LOADED;
  }

  override protected function get loadEventType():String {
    return LoadModuleEvent.LOAD_LOCALE;
  }

  override protected function get requestParameterName():String {
    return "locale";
  }

  override protected function get applicationCategory():String {
    return ModuleCategory.APPLICATION_RESOURCE;
  }

  override public function load(module:ModuleInfo):void {
    // autoupdate false, так как при установке localeChain в loadCompleteHandler будет все равно вызван update
    var moduleLoader:FlexModuleLoader = new ResourceModuleLoader(module, String(uri.get(module.category)), null, false);
    startLoad(moduleLoader);
  }

  override protected function loadCompleteHandler(loader:ModuleLoader, loaderInfo:LoaderInfo):void {
    ResourceManager.instance.localeChain = [loader.moduleInfo.id.classifier];

    super.loadCompleteHandler(loader, loaderInfo);
  }

  override protected function unloadApplicationWideModule():void {
    // @todo unloadResourceModule
    //ResourceManager.instance.unloadResourceModule(currentApplicationWideModule.uri, false);
  }
}
}