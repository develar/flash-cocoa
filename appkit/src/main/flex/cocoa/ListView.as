package cocoa {
import cocoa.plaf.ListViewSkin;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.basic.AbstractItemRenderer;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import mx.core.IVisualElement;
import mx.core.UIComponent;
import mx.core.mx_internal;

import spark.components.List;

use namespace mx_internal;

public class ListView extends List implements Viewable, Control, UIPartController {
  public function get hidden():Boolean {
    return !visible && !includeInLayout;
  }
  public function set hidden(value:Boolean):void {
    visible = !value;
    includeInLayout = !value;
  }

  private var _skinClass:Class;
  public function set skinClass(value:Class):void {
    _skinClass = value;
  }

  private var mySkin:ListViewSkin;

  override public function get skin():UIComponent {
    return UIComponent(mySkin);
  }

  private var _bordered:Boolean = true;
  public function set bordered(value:Boolean):void {
    _bordered = value;
  }

  protected var _action:Function;
  public function set action(value:Function):void {
    _action = value;
  }

  override protected function commitSelection(dispatchChangedEvents:Boolean = true):Boolean {
    var result:Boolean = super.commitSelection(dispatchChangedEvents);
    if (_action != null && result && dispatchChangedEvents) {
      _action();
    }

    return result;
  }

  private var laf:LookAndFeel;

  override protected function createChildren():void {
    laf = LookAndFeelUtil.find(parent);

    _skinClass = laf.getClass("ListView");
    mySkin = new _skinClass();
    mySkin.laf = laf;
    mySkin.bordered = _bordered;
    mySkin.verticalScrollPolicy = _verticalScrollPolicy;
    mySkin.horizontalScrollPolicy = _horizontalScrollPolicy;

    var skinAsDisplayObject:DisplayObject = DisplayObject(mySkin);
    addingChild(skinAsDisplayObject);
    $addChildAt(skinAsDisplayObject, 0);
    childAdded(skinAsDisplayObject);
  }

  public function get objectValue():Object {
    return selectedItem;
  }

  public function set objectValue(value:Object):void {
    selectedItem = value;
  }

  private var _verticalScrollPolicy:int = ScrollPolicy.AUTO;
  public function set verticalScrollPolicy(value:uint):void {
    _verticalScrollPolicy = value;
    if (skin != null) {
      ListViewSkin(skin).verticalScrollPolicy = _verticalScrollPolicy;
    }
  }

  private var _horizontalScrollPolicy:int = ScrollPolicy.AUTO;
  public function set horizontalScrollPolicy(value:uint):void {
    _horizontalScrollPolicy = value;
    if (skin != null) {
      ListViewSkin(skin).horizontalScrollPolicy = _horizontalScrollPolicy;
    }
  }

  public override function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void {
    if (renderer is AbstractItemRenderer) {
      AbstractItemRenderer(renderer).laf = laf;
    }

    super.updateRenderer(renderer, itemIndex, data);
  }

  // disable unwanted legacy
  include "../../unwantedLegacy.as";
  include "../../legacyConstraints.as";

  override public function getStyle(styleProp:String):* {
    if (styleProp == "skinClass") {
      return _skinClass;
    }
    else if (styleProp == "layoutDirection") {
      return layoutDirection;
    }
    else {
      return undefined;
    }
  }

  override protected function attachSkin():void {
  }

  public function uiPartAdded(id:String, instance:Object):void {
    this[id] = instance;
    partAdded(id, instance);
  }

  override public function parentChanged(p:DisplayObjectContainer):void {
    super.parentChanged(p);

    if (p != null) {
      _parent = p; // так как наше AbstractView не есть ни IStyleClient, ни ISystemManager
    }
  }
}
}