package cocoa {
import cocoa.plaf.SimpleSkin;

import flash.utils.Dictionary;

import mx.core.IVisualElement;
import mx.events.PropertyChangeEvent;
import mx.utils.OnDemandEventDispatcher;

use namespace ui;

[Abstract]
public class ComponentBase extends OnDemandEventDispatcher {
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

    if (!(skin is UIPartProvider)) {
      skin.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, skinPropertyChangeHandler);

      // PROPERTY_CHANGE вешается поздно, и некоторые skin part устанавливаются в конструкторе
      for (var skinPartId:String in skinParts) {
        var instance:Object = skin[skinPartId];
        if (instance != null && this[skinPartId] == null) {
          partAdded(skinPartId, instance);
        }
      }
    }
  }

  protected final function invalidateProperties():void {
    if (untypedSkin != null) {
      untypedSkin.invalidateProperties();
    }
  }

  protected function skinPropertyChangeHandler(event:PropertyChangeEvent):void {
    var skinPartId:String = String(event.property);
    if (skinPartId in skinParts) {
      partAdded(skinPartId, event.newValue);
    }
  }

  protected function partAdded(id:String, instance:Object):void {
    this[id] = instance;
    if ((int(skinParts[id]) & HANDLER_NOT_EXISTS) == 0) {
      this[id + "Added"]();
    }
  }

  public function get hidden():Boolean {
    return !IVisualElement(untypedSkin).visible && !IVisualElement(untypedSkin).includeInLayout;
  }

  public function set hidden(value:Boolean):void {
    IVisualElement(untypedSkin).visible = !value;
    IVisualElement(untypedSkin).includeInLayout = !value;
  }
}
}