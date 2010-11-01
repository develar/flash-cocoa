package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import mx.core.IVisualElement;
import mx.core.mx_internal;

import spark.components.DataGroup;

use namespace mx_internal;

public class FlexDataGroup extends DataGroup implements View, LookAndFeelProvider {
  // disable unwanted legacy

  include "../../legacyConstraints.as";

  include "../../unwantedLegacy.as";

  protected var _laf:LookAndFeel;
  public function get laf():LookAndFeel {
    return _laf;
  }

  public function set laf(value:LookAndFeel):void {
    _laf = value;
  }

  override public function parentChanged(p:DisplayObjectContainer):void {
    super.parentChanged(p);

    if (p != null) {
      _parent = p; // так как наше AbstractView не есть ни IStyleClient, ни ISystemManager
    }
  }

  public final function addDisplayObject(displayObject:DisplayObject, index:int = -1):void {
    $addChildAt(displayObject, index == -1 ? numChildren : index);
  }

  public final function removeDisplayObject(displayObject:DisplayObject):void {
    $removeChild(displayObject);
  }

  override public function updateRenderer(renderer:IVisualElement, itemIndex:int, data:Object):void {
    super.updateRenderer(renderer, itemIndex, data);

    if (renderer is LookAndFeelProvider && _laf != null) {
      LookAndFeelProvider(renderer).laf = _laf;
    }
  }
}
}