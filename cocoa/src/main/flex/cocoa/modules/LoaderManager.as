package cocoa.modules {
import cocoa.modules.events.LoadModuleEvent;
import cocoa.modules.loaders.ModuleLoader;
import cocoa.modules.loaders.SWFModuleLoader;

import flash.display.LoaderInfo;

import org.flyti.plexus.AbstractComponent;
import org.flyti.plexus.configuration.Configurable;
import org.flyti.util.ArrayList;
import org.flyti.util.Map;

public class LoaderManager extends AbstractComponent implements Configurable {
  public var uri:Map/*<String,String>*/;

  private var _currentLoaders:ArrayList/*<com.thewebproduction.modules.loaders.SWFModuleLoader>*/ = new ArrayList();
  public function get currentLoaders():ArrayList {
    return _currentLoaders;
  }

  [Abstract]
  protected function get initialModuleLoadedEventType():String {
    throw new Error("abstract");
  }

  [Abstract]
  protected function get moduleLoadedEventType():String {
    throw new Error("abstract");
  }

  [Abstract]
  protected function get loadEventType():String {
    throw new Error("abstract");
  }

  [Abstract]
  protected function get applicationCategory():String {
    throw new Error("abstract");
  }

  [Abstract]
  protected function get requestParameterName():String {
    throw new Error("abstract");
  }

  public function load(moduleInfo:ModuleInfo):void {
    assert(!moduleInfo.loaded);
    assert(!moduleInfo.ready);

    moduleInfo.loaded = true;

    var moduleLoader:ModuleLoader = new SWFModuleLoader(moduleInfo, moduleInfo.uri == null ? String(uri.get(moduleInfo.category)) : null);
    startLoad(moduleLoader);
  }

  protected function startLoad(loader:ModuleLoader):void {
    loader.completeHandler = loadCompleteHandler;
    loader.errorHandler = loadErrorHandler;

    currentLoaders.addItem(loader);
    loader.load();
  }

  protected function loadErrorHandler(loader:ModuleLoader):void {
    clear(loader);
  }

  protected function loadCompleteHandler(loader:ModuleLoader, loaderInfo:LoaderInfo):void {
    dispatchContextEvent(new LoadModuleEvent(moduleLoadedEventType, loader.moduleInfo, loaderInfo));

    clear(loader);
  }

  protected function clear(loader:ModuleLoader):void {
    currentLoaders.removeItemAt(currentLoaders.getItemIndex(loader));
  }
}
}