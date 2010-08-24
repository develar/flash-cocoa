package cocoa {
import flash.display.DisplayObjectContainer;

import mx.core.mx_internal;

import spark.components.DataGroup;

use namespace mx_internal;

public class FlexDataGroup extends DataGroup {
  // disable unwanted legacy

  include "../../legacyConstraints.as";

  include "../../unwantedLegacy.as";

  override public function parentChanged(p:DisplayObjectContainer):void {
    super.parentChanged(p);

    if (p != null) {
      _parent = p; // так как наше AbstractView не есть ни IStyleClient, ни ISystemManager
    }
  }
}
}