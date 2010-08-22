package cocoa.modules.loaders {
import cocoa.modules.ModuleInfo;

import flash.system.ApplicationDomain;

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
}
}