package cocoa.modules.loaders {
import cocoa.message.ApplicationErrorEvent;

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.utils.ByteArray;
import flash.utils.IDataInput;
import flash.utils.getDefinitionByName;

import org.flyti.plexus.Dispatcher;

public class Loader {
  protected var uri:String;

  /**
   * (loader:Loader, loaderInfo:LoaderInfo):void
   */
  private var _completeHandler:Function;
  public function set completeHandler(value:Function):void {
    assert(_completeHandler == null);
    _completeHandler = value;
  }

  private var _errorHandler:Function;
  public function set errorHandler(value:Function):void {
    assert(_errorHandler == null);
    _errorHandler = value;
  }

  private static var fileClass:Class;
  if (ApplicationDomain.currentDomain.hasDefinition("flash.filesystem.File")) {
    fileClass = getDefinitionByName("flash.filesystem.File") as Class;
  }

  public function Loader(uri:String = null, applicationDomain:ApplicationDomain = null) {
    this.uri = uri;
    _applicationDomain = applicationDomain;
  }

  private var _applicationDomain:ApplicationDomain;
  public function get applicationDomain():ApplicationDomain {
    return _applicationDomain;
  }

  protected function get loadErrorMessage():String {
    return "errorLoad";
  }

  public function load():void {
    var loader:flash.display.Loader = new flash.display.Loader();
    addLoaderListeners(loader.contentLoaderInfo);
    adjustURI();

    var loaderContext:LoaderContext = new LoaderContext(false, applicationDomain);

    const protocolNotSpecified:Boolean = fileClass != null && uri.indexOf(":/") == -1;
    if (fileClass != null && (protocolNotSpecified || uri.indexOf("file://") == 0)) {
      var filePath:String = uri;
      if (!protocolNotSpecified) {
        filePath = filePath.substr(7);
      }

      if (filePath.charAt(0) != "/") {
        filePath = fileClass.applicationDirectory.nativePath + "/" + filePath;
      }
      var file:Object = new fileClass(filePath);

      const fileStreamClass:Class = Class(getDefinitionByName("flash.filesystem.FileStream"));
      var fileStream:Object = new fileStreamClass();
      fileStream.open(file, "read");
      var data:ByteArray = new ByteArray();
      IDataInput(fileStream).readBytes(data);
      fileStream.close();

      loaderContext.allowCodeImport = true;
      loader.loadBytes(data, loaderContext);
    }
    else {
      loader.load(new URLRequest(uri), loaderContext);
    }
  }

  protected function adjustURI():void {

  }

  private function addLoaderListeners(dispatcher:LoaderInfo):void {
    dispatcher.addEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
    dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
    dispatcher.addEventListener(Event.COMPLETE, loadCompleteHandler);
  }

  private function removeLoaderListeners(dispatcher:LoaderInfo):void {
    dispatcher.removeEventListener(IOErrorEvent.IO_ERROR, loadErrorHandler);
    dispatcher.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, loadErrorHandler);
    dispatcher.removeEventListener(Event.COMPLETE, loadCompleteHandler);
  }

  protected function loadCompleteHandler(event:Event):void {
    _completeHandler(this, event.currentTarget as LoaderInfo);
    clear(event);

    _completeHandler = null;
    _errorHandler = null;
  }

  protected function loadErrorHandler(event:Event):void {
    if (_errorHandler != null) {
      _errorHandler(this);
    }
    Dispatcher.dispatch(new ApplicationErrorEvent(loadErrorMessage, event));

    clear(event);

    _completeHandler = null;
    _errorHandler = null;
  }

  protected function clear(event:Event):void {
    removeLoaderListeners(LoaderInfo(event.currentTarget));
  }
}
}