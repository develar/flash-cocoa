package cocoa.modules.loaders
{
import cocoa.message.ApplicationErrorEvent;
import cocoa.modules.events.LoaderEvent;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.IDataInput;
import flash.utils.getDefinitionByName;

import org.flyti.plexus.Dispatcher;

public class Loader extends EventDispatcher
{
	protected var uri:String;

	private static var fileClass:Class;
	if (ApplicationDomain.currentDomain.hasDefinition("flash.filesystem.File"))
	{
		fileClass = getDefinitionByName("flash.filesystem.File") as Class;
	}

	public function Loader(uri:String = null, applicationDomain:ApplicationDomain = null)
	{
		this.uri = uri;
		_applicationDomain = applicationDomain;
	}

	private var _applicationDomain:ApplicationDomain;
	public function get applicationDomain():ApplicationDomain
	{
		return _applicationDomain;
	}

	protected function get loadErrorMessage():String
	{
		return "errorLoad";
	}

	public function load():void
	{
		var loader:flash.display.Loader = new flash.display.Loader();
		addLoaderListeners(loader.contentLoaderInfo);
		adjustURI();

		var loaderContext:LoaderContext = new LoaderContext(false, applicationDomain);

		const protocolNotSpecified:Boolean = fileClass != null && uri.indexOf(":/") == -1;
		if (fileClass != null && (protocolNotSpecified || uri.indexOf("file://") == 0))
		{
			var filePath:String = uri;
			if (!protocolNotSpecified)
			{
				filePath = filePath.substr(7);
			}

			if (filePath.charAt(0) != "/")
			{
				filePath = Object(fileClass).applicationDirectory.nativePath + "/" + filePath;
			}
			var file:Object = new fileClass(filePath);

			const fileStreamClass:Class = Class(getDefinitionByName("flash.filesystem.FileStream"));
			var fileStream:Object = new fileStreamClass();
			fileStream.open(file, "read");
			var data:ByteArray = new ByteArray();
			IDataInput(fileStream).readBytes(data);
			fileStream.close();

			loaderContext["allowLoadBytesCodeExecution"] = true;
			loader.loadBytes(data, loaderContext);
		}
		else
		{
			loader.load(new URLRequest(uri), loaderContext);
		}
	}

	protected function adjustURI():void
	{

	}

	protected function addLoaderListeners(dispatcher:LoaderInfo):void
	{
		dispatcher.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
		dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
		dispatcher.addEventListener(Event.COMPLETE, loadCompleteHandler);
	}

	private function removeLoaderListeners(dispatcher:LoaderInfo):void
	{
		dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
		dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
		dispatcher.removeEventListener(Event.COMPLETE, loadCompleteHandler);
	}

	protected function dispatchCompleteEvent(event:Event):void
	{
		dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, LoaderInfo(event.currentTarget)));
	}

	protected function dispatchErrorEvent(event:Event):void
	{
		dispatchEvent(new LoaderEvent(LoaderEvent.ERROR, LoaderInfo(event.currentTarget)));
		Dispatcher.dispatch(new ApplicationErrorEvent(loadErrorMessage, event));
	}

	protected function loadCompleteHandler(event:Event):void
	{
		dispatchCompleteEvent(event);
		clear(event);
	}

	protected function loadErrorHandler(event:Event):void
	{
		dispatchErrorEvent(event);
		clear(event);
	}

	protected function clear(event:Event):void
	{
		removeLoaderListeners(LoaderInfo(event.currentTarget));
	}
}
}