package cocoa.modules {
import cocoa.modules.loaders.ModuleLoader;

public class ModuleLoaderQueue {
  private var loaders:Vector.<ModuleLoader> = new Vector.<ModuleLoader>();
  private var completeHandlers:Vector.<Function> = new Vector.<Function>();

  private var currentIndex:int = 0;

  public function add(loader:ModuleLoader, completeHandler:Function = null):void {
    var index:int = loaders.length;
    loaders[index] = loader;
    completeHandlers[index] = completeHandler;
  }

  public function get(index:int):ModuleLoader {
    return loaders[index];
  }

  public function get hasNext():Boolean {
    return currentIndex < loaders.length;
  }

  public function getCurrentCompleteHandler():Function {
    return completeHandlers[currentIndex - 1];
  }

  public function next():ModuleLoader {
    return loaders[currentIndex++];
  }

  public function initialize():void {
    loaders.fixed = true;
    completeHandlers.fixed = true;
  }
}
}