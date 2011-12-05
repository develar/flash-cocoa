package cocoa.modules {
import cocoa.modules.events.LoadModuleEvent;
import cocoa.modules.loaders.FlexModuleLoader;
import cocoa.modules.loaders.ModuleLoader;

import flash.display.LoaderInfo;

import mx.core.FlexGlobals;
import mx.events.BrowserChangeEvent;

/**
 * При инициализации приложения путем события ModuleCategoryURIMapEvent отображаем категорию модуля на URI.
 * По умолчанию должно быть определено две — applicationStyle и applicationResource — для applicationWide module.
 */
public class ModuleManager extends LoaderManager {
  protected var currentApplicationWideModule:ModuleInfo;
  protected var applicationWideModules:Vector.<ModuleInfo>;

  override protected function get moduleLoadedEventType():String {
    return LoadModuleEvent.MODULE_LOADED;
  }

  override protected function get loadEventType():String {
    return LoadModuleEvent.LOAD_MODULE;
  }

  override public function load(module:ModuleInfo):void {
    var moduleLoader:FlexModuleLoader = new FlexModuleLoader(module, String(uri.get(module.category)));
    startLoad(moduleLoader);
  }

  public function preinitialize():void {
    //		if (!(requestParameterName in BrowserManager.instance.parameters))
    //		{
    var parameters:Object = FlexGlobals.topLevelApplication.parameters;
    var parameterName:String = requestParameterName + "s";
    if (parameterName in parameters) {
      var modules:Array = String(parameters[parameterName]).split(/\s*,\s*/);
      loadApplicationWideModuleByURI(modules[0]);
    }
    //		}
  }

  public function browserUrlChangeHandler(event:BrowserChangeEvent):void {
    loadApplicationWideModuleByURI();
  }

  protected function loadApplicationWideModuleByURI(uri:String = null):void {
    if (uri == null) {
      //			var data:Object = BrowserManager.instance.parameters;
      //			if (requestParameterName in data)
      //			{
      //				uri = String(data[requestParameterName]);
      //			}
      //			else
      //			{
      return;
      //			}
    }

    var suggestedModule:ModuleInfo = new ModuleInfoImpl(new ArtifactCoordinate(uri));
    if (currentApplicationWideModule == null || !currentApplicationWideModule.equal(suggestedModule)) {
      if (applicationWideModules != null) {
        for each (var module:ModuleInfo in applicationWideModules) {
          if (module.equal(suggestedModule)) {
            suggestedModule = module;
            break;
          }
        }
      }

      suggestedModule.category = applicationCategory;
      dispatchContextEvent(new LoadModuleEvent(loadEventType, suggestedModule));
    }
  }

  override protected function loadCompleteHandler(loader:ModuleLoader, loaderInfo:LoaderInfo):void {
    if (loader.moduleInfo.category == applicationCategory) {
      if (currentApplicationWideModule != null) {
        unloadApplicationWideModule();
      }
      else {
        dispatchContextEvent(new LoadModuleEvent(initialModuleLoadedEventType, loader.moduleInfo));
      }
      currentApplicationWideModule = loader.moduleInfo;
      // @todo установить новый skin в BrowserManager
    }
    else {
      dispatchContextEvent(new LoadModuleEvent(moduleLoadedEventType, loader.moduleInfo));
    }

    clear(loader);
  }

  [Abstract]
  protected function unloadApplicationWideModule():void {
    throw new Error("abstract");
  }
}
}