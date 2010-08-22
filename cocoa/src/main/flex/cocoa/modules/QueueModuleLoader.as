package cocoa.modules {
import cocoa.modules.loaders.ModuleLoader;

import flash.display.LoaderInfo;
import flash.utils.Dictionary;

public class QueueModuleLoader {
  private var queueLoaderMap:Dictionary;

  /**
   * (queue:ModuleLoaderQueue):void
   */
  private var completeHandler:Function;
  private var errorHandler:Function;
  
  public function QueueModuleLoader(completeHandler:Function, errorHandler:Function = null) {
    this.completeHandler = completeHandler;
    this.errorHandler = errorHandler;
  }

  public function load(queue:ModuleLoaderQueue):void {
    queue.initialize();

    if (queueLoaderMap == null) {
      queueLoaderMap = new Dictionary();
    }

    loadNext(queue);
  }

  private function loadNext(queue:ModuleLoaderQueue):void {
    var loader:ModuleLoader = queue.next();
    loader.completeHandler = loadCompleteHandler;
    loader.errorHandler = loadErrorHandler;

    queueLoaderMap[loader] = queue;
    loader.load();
  }

  protected function loadCompleteHandler(loader:ModuleLoader, loaderInfo:LoaderInfo):void {

    var queue:ModuleLoaderQueue = queueLoaderMap[loader];
    delete queueLoaderMap[loader];
    loader.moduleInfo.ready = true;

    var itemCompleteHandler:Function = queue.getCurrentCompleteHandler();
    if (itemCompleteHandler != null) {
      itemCompleteHandler(loader, loaderInfo);
    }

    if (queue.hasNext) {
      loadNext(queue);
    }
    else {
      completeHandler(queue);
    }
  }

  protected function loadErrorHandler(loader:ModuleLoader):void {
    delete queueLoaderMap[loader];
  }
}
}