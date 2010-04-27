package cocoa.data
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.utils.Dictionary;

import org.flyti.util.HashMap;
import org.flyti.util.Map;

public class AbstractDataLoader extends EventDispatcher
{
	private const completeHandlers:Dictionary = new Dictionary();

	protected var localization:Map;

	protected function createLoader(completeHandler:Function, dataFormat:String = URLLoaderDataFormat.TEXT):URLLoader
	{
		var loader:URLLoader = new URLLoader();
		loader.dataFormat = dataFormat;

		loader.addEventListener(Event.COMPLETE, handler);
		loader.addEventListener(IOErrorEvent.IO_ERROR, handler);
		loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handler);

		completeHandlers[loader] = completeHandler;

		return loader;
	}

	private function handler(event:Event):void
	{
		var loader:URLLoader = URLLoader(event.currentTarget);
		loader.removeEventListener(Event.COMPLETE, handler);
		loader.removeEventListener(IOErrorEvent.IO_ERROR, handler);
		loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, handler);

		var completeHandler:Function = completeHandlers[loader] as Function;
		delete completeHandlers[loader];
		
		if (event.type == Event.COMPLETE)
		{
			completeHandler(loader);
		}
		else
		{
			throw new Error(event);
		}
	}

	protected function parseLabel(labelXMLList:XMLList):Map
	{
		var labels:Object = new Object();
		for each (var labelXML:XML in labelXMLList)
		{
			labels[labelXML.@lang] = labelXML.toString();
		}
		return new HashMap(false, labels);
	}

	protected function checkAvailability():void
	{
		throw new Error("Abstract");
	}
}
}