package cocoa {
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;

import net.miginfocom.layout.ComponentWrapper;

public interface View extends ComponentWrapper {
  function init(laf:LookAndFeel, container:DisplayObjectContainer):void;

  function validate():void;
}
}