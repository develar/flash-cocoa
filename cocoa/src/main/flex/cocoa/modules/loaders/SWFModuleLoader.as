package cocoa.modules.loaders {
import cocoa.message.ApplicationErrorEvent;
import cocoa.modules.ModuleInfo;
import cocoa.modules.events.LoaderEvent;
import cocoa.modules.events.ModuleLoaderEvent;

import flash.display.LoaderInfo;
import flash.events.Event;
import flash.system.ApplicationDomain;

import org.flyti.plexus.Dispatcher;

public class SWFModuleLoader extends Loader implements ModuleLoader {
  private var rootURI:String;

  public function SWFModuleLoader(moduleInfo:ModuleInfo, rootURI:String = null, applicationDomain:ApplicationDomain = null) {
    _moduleInfo = moduleInfo;
    this.rootURI = rootURI;

    super(null, applicationDomain);
  }

  protected var _moduleInfo:ModuleInfo;
  public function get moduleInfo():ModuleInfo {
    return _moduleInfo;
  }

  override protected function adjustURI():void {
    if (_moduleInfo.uri == null) {
      _moduleInfo.absolutizeURI(rootURI);
    }

    uri = _moduleInfo.uri;
  }

  override protected function dispatchCompleteEvent(event:Event):void {
    dispatchEvent(new ModuleLoaderEvent(LoaderEvent.COMPLETE, this, event.currentTarget is LoaderInfo ? LoaderInfo(event.currentTarget) : null));
  }

  override protected function dispatchErrorEvent(event:Event):void {
    dispatchEvent(new ModuleLoaderEvent(LoaderEvent.ERROR, this));
    Dispatcher.dispatch(new ApplicationErrorEvent(loadErrorMessage, [event, _moduleInfo]));
  }
}
}