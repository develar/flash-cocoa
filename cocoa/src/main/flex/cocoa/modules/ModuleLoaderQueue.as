package cocoa.modules
{
import cocoa.modules.loaders.ModuleLoader;

public class ModuleLoaderQueue
{
	public var loaders:Vector.<ModuleLoader> = new Vector.<ModuleLoader>();
	private var currentIndex:int = 0;

	public function add(loader:ModuleLoader):void
	{
		loaders.push(loader);
	}

	public function get(index:int):ModuleLoader
	{
		return loaders[index];
	}

	public function get hasNext():Boolean
	{
		return currentIndex < loaders.length;
	}

	public function next():ModuleLoader
	{
		return loaders[currentIndex++];
	}

	public function initialize():void
	{
		loaders.fixed = true;
	}
}
}