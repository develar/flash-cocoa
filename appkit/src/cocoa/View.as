package cocoa {
import flash.display.DisplayObject;

import net.miginfocom.layout.ComponentWrapper;

public interface View extends ComponentWrapper {
  function init(container:Container):void;

  function validate():void;

  function get enabled():Boolean;
}
}