package cocoa.modules.events
{
import cocoa.modules.ModuleLoaderQueue;

import flash.events.Event;

public class QueueModuleLoaderEvent extends Event
{
	public function QueueModuleLoaderEvent(queue:ModuleLoaderQueue)
	{
		_queue = queue;

		super(Event.COMPLETE);
	}

	private var _queue:ModuleLoaderQueue;
	public function get queue():ModuleLoaderQueue
	{
		return _queue;
	}
}
}