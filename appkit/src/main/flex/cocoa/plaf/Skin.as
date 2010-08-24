package cocoa.plaf {
import cocoa.Component;
import cocoa.View;
import cocoa.layout.LayoutMetrics;

import mx.managers.IToolTipManagerClient;

public interface Skin extends SimpleSkin, IToolTipManagerClient, View {
  function set layoutMetrics(value:LayoutMetrics):void;

  function get component():Component;

  function attach(component:Component, laf:LookAndFeel):void;
}
}