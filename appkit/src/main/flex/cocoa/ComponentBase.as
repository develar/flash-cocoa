package cocoa {
import cocoa.plaf.SimpleSkin;

import flash.utils.Dictionary;

use namespace ui;

[Abstract]
public class ComponentBase extends ComponentWrapperImpl {
  protected static const HANDLER_NOT_EXISTS:int = 2;

  //noinspection JSUnusedLocalSymbols
  protected function getSkinPartFlags(id:String):int {
    return 0;
  }

  protected static function _cl(own:Dictionary, parent:Dictionary):void {
    for (var id:Object in parent) {
      own[id] = parent[id];
    }
  }

  private static const _skinParts:Dictionary = new Dictionary();
  protected function get skinParts():Dictionary {
    return _skinParts;
  }

  private var untypedSkin:SimpleSkin;

  public function uiPartAdded(id:String, instance:Object):void {
    partAdded(id, instance);
  }

  protected function listenSkinParts(skin:SimpleSkin):void {
    untypedSkin = skin;
  }

  protected final function invalidateProperties():void {
    if (untypedSkin != null) {
      //untypedSkin.invalidateProperties();
    }
  }

  protected function partAdded(id:String, instance:Object):void {
    this[id] = instance;
    if ((int(skinParts[id]) & HANDLER_NOT_EXISTS) == 0) {
      this[id + "Added"]();
    }
  }
}
}