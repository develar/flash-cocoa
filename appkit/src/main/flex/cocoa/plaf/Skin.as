package cocoa.plaf {
import cocoa.Component;
import cocoa.layout.LayoutMetrics;

public interface Skin extends SimpleSkin {
  function set layoutMetrics(value:LayoutMetrics):void;

  function get component():Component;

  function attach(component:Component, laf:LookAndFeel):void;
}
}