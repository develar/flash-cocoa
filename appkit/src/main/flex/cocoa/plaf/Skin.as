package cocoa.plaf {
import cocoa.Component;
import cocoa.layout.LayoutMetrics;

import mx.managers.IToolTipManagerClient;

public interface Skin extends SimpleSkin, IToolTipManagerClient {
  function set layoutMetrics(value:LayoutMetrics):void;

  function get component():Component;

  function attach(component:Component, laf:LookAndFeel):void;
}
}