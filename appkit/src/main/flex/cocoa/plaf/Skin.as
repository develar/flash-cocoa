package cocoa.plaf {
import cocoa.Component;

public interface Skin extends SimpleSkin {
  function get component():Component;

  function attach(component:Component, laf:LookAndFeel):void;
}
}