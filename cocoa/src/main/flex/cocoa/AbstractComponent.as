package cocoa {
import cocoa.layout.LayoutMetrics;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;
import cocoa.resources.ResourceManager;

import flash.events.Event;

import mx.core.IMXMLObject;
import mx.core.IStateClient2;
import mx.core.IVisualElement;

use namespace ui;

[Abstract]
public class AbstractComponent extends ComponentBase implements Component, IMXMLObject {
  // только как прокси
  private var layoutMetrics:LayoutMetrics;

  protected var resourceManager:ResourceManager;

  protected var _skinClass:Class;
  public function set skinClass(value:Class):void {
    _skinClass = value;
  }

  private var _skin:Skin;
  public function get skin():Skin {
    return _skin;
  }

  protected var skinV:IVisualElement;

  protected function listenResourceChange():void {
    resourceManager = ResourceManager.instance;
    resourceManager.addEventListener(Event.CHANGE, resourceChangeHandler, false, 0, true);
  }

  protected function resourceChangeHandler(event:Event):void {
    resourcesChanged();
  }

  protected function resourcesChanged():void {

  }

  /* proxy for compiler */
  public function set left(value:Number):void {
    if (layoutMetrics == null) {
      layoutMetrics = new LayoutMetrics();
    }
    layoutMetrics.left = value;
  }

  public function set right(value:Number):void {
    if (layoutMetrics == null) {
      layoutMetrics = new LayoutMetrics();
    }
    layoutMetrics.right = value;
  }

  public function set top(value:Number):void {
    if (layoutMetrics == null) {
      layoutMetrics = new LayoutMetrics();
    }
    layoutMetrics.top = value;
  }

  public function set bottom(value:Number):void {
    if (layoutMetrics == null) {
      layoutMetrics = new LayoutMetrics();
    }
    layoutMetrics.bottom = value;
  }

  public function set horizontalCenter(value:Number):void {
    if (layoutMetrics == null) {
      layoutMetrics = new LayoutMetrics();
    }
    layoutMetrics.horizontalCenter = value;
  }

  public function set verticalCenter(value:Number):void {
    if (layoutMetrics == null) {
      layoutMetrics = new LayoutMetrics();
    }
    layoutMetrics.verticalCenter = value;
  }

  public function set baseline(value:Object):void {
    if (layoutMetrics == null) {
      layoutMetrics = new LayoutMetrics();
    }
    layoutMetrics.baseline = Number(value);
  }

  public function set percentWidth(value:Number):void {
    if (layoutMetrics == null) {
      layoutMetrics = new LayoutMetrics();
    }
    layoutMetrics.flags |= LayoutMetrics.PERCENT_WIDTH;
    layoutMetrics.width = value;
  }

  public function set percentHeight(value:Number):void {
    if (layoutMetrics == null) {
      layoutMetrics = new LayoutMetrics();
    }
    layoutMetrics.flags |= LayoutMetrics.PERCENT_HEIGHT;
    layoutMetrics.height = value;
  }

  [PercentProxy("percentWidth")]
  public function set width(value:Number):void {
    if (layoutMetrics == null) {
      layoutMetrics = new LayoutMetrics();
    }
    layoutMetrics.width = value;
  }

  [PercentProxy("percentHeight")]
  public function set height(value:Number):void {
    if (layoutMetrics == null) {
      layoutMetrics = new LayoutMetrics();
    }
    layoutMetrics.height = value;
  }

  /* Component */
  public function createView(laf:LookAndFeel):Skin {
    if (_skinClass == null) {
      _skinClass = laf.getClass(lafKey);
    }
    _skin = new _skinClass();
    _skinClass = null;
    if (!_enabled) {
      _skin.enabled = false;
    }

    skinV = _skin;
    if (layoutMetrics != null) {
      _skin.layoutMetrics = layoutMetrics;
      layoutMetrics = null;
    }
    _skin.attach(this, laf);
    skinAttachedHandler();
    listenSkinParts(_skin);
    return _skin;
  }

  public final function get lafKey():String {
    return _lafSubkey == null ? primaryLaFKey : (_lafSubkey + "." + primaryLaFKey);
  }

  protected var _lafSubkey:String;
  public final function set lafSubkey(value:String):void {
    _lafSubkey = value;
  }

  protected function get primaryLaFKey():String {
    throw new Error("abstract");
  }

  protected function skinAttachedHandler():void {

  }

  public function commitProperties():void {
    if (skinStateIsDirty) {
      IStateClient2(_skin).currentState = getCurrentSkinState();
      skinStateIsDirty = false;
    }
  }

  private var skinStateIsDirty:Boolean = false;

  protected function invalidateSkinState():void {
    if (!skinStateIsDirty) {
      skinStateIsDirty = true;
      invalidateProperties();
    }
  }

  protected function getCurrentSkinState():String {
    return null;
  }

  protected var _enabled:Boolean = true;
  public function get enabled():Boolean {
    return _enabled;
  }

  public function set enabled(value:Boolean):void {
    if (value == _enabled) {
      return;
    }

    _enabled = value;
    if (_skin != null) {
      _skin.enabled = _enabled;
    }

    if (hasEventListener("enabledChanged")) {
      dispatchEvent(new Event("enabledChanged"));
    }
  }

  /* IID */
  private var _id:String;
  public function get id():String {
    return _id;
  }

  public function set id(value:String):void {
    _id = value;
  }

  public function initialized(document:Object, id:String):void {
    this.id = id;
  }
}
}