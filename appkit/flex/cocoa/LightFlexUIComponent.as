package cocoa {
import flash.display.DisplayObject;

import mx.core.UIComponent;
import mx.core.mx_internal;

use namespace mx_internal;

public class LightFlexUIComponent extends UIComponent implements View {
  include "../../unwantedLegacy.as";

  include "../../legacyConstraints.as";

  override public function set currentState(value:String):void {
  }

  public final function addDisplayObject(displayObject:DisplayObject, index:int = -1):void {
    $addChildAt(displayObject, index == -1 ? numChildren : index);
  }

  public final function removeDisplayObject(displayObject:DisplayObject):void {
    $removeChild(displayObject);
  }
}
}
