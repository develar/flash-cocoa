package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;
import cocoa.resources.ResourceManager;

import flash.events.Event;

import mx.core.IMXMLObject;

use namespace ui;

[Abstract]
public class AbstractComponent extends ComponentBase implements Component, IMXMLObject {
  protected var resourceManager:ResourceManager;
  
  private var _id:String;
  public function get id():String {
    return _id;
  }

  public function set id(value:String):void {
    _id = value;
  }

  protected var _skinClass:Class;
  public function set skinClass(value:Class):void {
    _skinClass = value;
  }

  private var _skin:Skin;
  public function get skin():Skin {
    return _skin;
  }

  protected function listenResourceChange():void {
    resourceManager = ResourceManager.instance;
    resourceManager.addEventListener(Event.CHANGE, resourceChangeHandler, false, 0, true);
  }

  protected function resourceChangeHandler(event:Event):void {
    resourcesChanged();
  }

  protected function resourcesChanged():void {

  }

  public final function createView(laf:LookAndFeel):Skin {
    _lafKey = _lafSubkey == null ? primaryLaFKey : (_lafSubkey + "." + primaryLaFKey);
    if (laf.controlSize != null) {
      _lafKey = laf.controlSize + "." + _lafKey;
    }

    preSkinCreate(laf);

    if (_skinClass == null) {
      _skinClass = laf.getClass(_lafKey);
    }
    _skin = new _skinClass();
    _skinClass = null;
    _skin.attach(this, laf);
    skinAttached();
    listenSkinParts(_skin);
    return _skin;
  }

  private var _lafKey:String;
  public final function get lafKey():String {
    return _lafKey;
  }

  protected var _lafSubkey:String;
  public final function set lafSubkey(value:String):void {
    _lafSubkey = value;
  }

  protected function get primaryLaFKey():String {
    throw new Error("abstract");
  }

  protected function preSkinCreate(laf:LookAndFeel):void {

  }

  protected function skinAttached():void {

  }

  public function commitProperties():void {
  }

  protected function getCurrentSkinState():String {
    return null;
  }

  public function initialized(document:Object, id:String):void {
    _id = id;
  }
}
}