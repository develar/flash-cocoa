package cocoa.plaf {
import cocoa.Component;

import flash.display.DisplayObjectContainer;

public interface Skin extends SimpleSkin {
  function get hostComponent():Component;

  function attach(component:Component, container:DisplayObjectContainer, laf:LookAndFeel):void;
}
}