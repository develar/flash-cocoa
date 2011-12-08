package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

import flash.display.DisplayObjectContainer;
import flash.utils.Dictionary;

use namespace ui;

[Abstract]
public class ObjectBackedSkinnableView extends ObjectBackedView implements SkinnableView {
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

  public function uiPartAdded(id:String, instance:Object):void {
    partAdded(id, instance);
  }

  protected final function invalidateProperties():void {
    if (_skin != null) {
      _skin.hostComponentPropertyChanged();
    }
  }

  protected function partAdded(id:String, instance:Object):void {
    this[id] = instance;
    if ((int(skinParts[id]) & HANDLER_NOT_EXISTS) == 0) {
      this[id + "Added"]();
    }
  }

  protected var _skinClass:Class;
  public function set skinClass(value:Class):void {
    _skinClass = value;
  }

  private var _skin:Skin;
  public function get skin():Skin {
    return _skin;
  }

  override public function get x():Number {
    return _skin.x;
  }

  override public function get y():Number {
    return _skin.y;
  }

  override public function get actualWidth():int {
    return _skin.actualWidth;
  }

  override public function get actualHeight():int {
    return _skin.actualHeight;
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    return _skin.getMinimumWidth(hHint);
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return _skin.getMinimumHeight(wHint);
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    return _skin.getPreferredWidth(hHint);
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    return _skin.getPreferredHeight(wHint);
  }

  override public function getMaximumWidth(hHint:int = -1):int {
    return _skin.getMaximumWidth(hHint);
  }

  override public function getMaximumHeight(wHint:int = -1):int {
    return _skin.getMaximumHeight(wHint);
  }

  override public function setLocation(x:Number, y:Number):void {
    skin.setLocation(x, y);
  }

  override public function setSize(w:int, h:int):void {
    skin.setSize(w, h);
  }

  override public function setBounds(x:Number, y:Number, w:int, h:int):void {
    skin.setBounds(x, y, w, h);
  }

  override public final function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    _lafKey = _lafSubkey == null ? primaryLaFKey : (_lafSubkey + "." + primaryLaFKey);
    if (laf.controlSize != null) {
      _lafKey = laf.controlSize + "." + _lafKey;
    }

    preSkinCreate(laf);

    if (_skinClass == null) {
      _skinClass = laf.getClass(_lafKey);
    }
    _skin = new _skinClass();
    _skin.setVisibleAndBurnInHellAdobe(visible);
    _skinClass = null;
    _skin.attach(this);
    _skin.addToSuperview(displayObjectContainer, laf, superview);
    skinAttached();
  }

  override public function removeFromSuperview():void {
    _skin.removeFromSuperview();
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

  override public function set visible(value:Boolean):void {
    super.visible = value;
    if (_skin != null) {
      _skin.setVisibleAndBurnInHellAdobe(value);
    }
  }

  override public function set enabled(value:Boolean):void {
    super.enabled = value;
    if (_skin != null) {
      _skin.enabled = value;
    }
  }
}
}