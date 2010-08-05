package cocoa.modules
{
import cocoa.modules.events.LoaderEvent;
import cocoa.modules.events.ModuleLoaderEvent;
import cocoa.modules.events.QueueModuleLoaderEvent;
import cocoa.modules.loaders.ModuleLoader;

import flash.events.EventDispatcher;

import org.flyti.util.HashMap;
import org.flyti.util.Map;

public class QueueModuleLoader extends EventDispatcher
{
	private var queueLoaderMap:Map;

	public function load(queue:ModuleLoaderQueue):void
	{
		queue.initialize();

		if (queueLoaderMap == null)
		{
			queueLoaderMap = new HashMap();
		}

		loadNext(queue);
	}

	private function loadNext(queue:ModuleLoaderQueue):void
	{
		var loader:ModuleLoader = queue.next();
		loader.addEventListener(LoaderEvent.COMPLETE, loadCompleteHandler);
		loader.addEventListener(LoaderEvent.ERROR, loadErrorHandler);

		queueLoaderMap.put(loader, queue);
		loader.load();
	}

	protected function loadCompleteHandler(event:ModuleLoaderEvent):void
	{
		removeLoaderEventListeners(event.loader);

		var queue:ModuleLoaderQueue = ModuleLoaderQueue(queueLoaderMap.remove(event.loader));
		event.loader.moduleInfo.ready = true;
		if (queue.hasNext)
		{
			loadNext(queue);
		}
		else
		{
			dispatchEvent(new QueueModuleLoaderEvent(queue));
		}
	}

	protected function loadErrorHandler(event:ModuleLoaderEvent):void
	{
		removeLoaderEventListeners(event.loader);
		queueLoaderMap.remove(event.loader);
	}

	protected function removeLoaderEventListeners(loader:ModuleLoader):void
	{
		loader.removeEventListener(LoaderEvent.COMPLETE, loadCompleteHandler);
		loader.removeEventListener(LoaderEvent.ERROR, loadErrorHandler);
	}
}
}