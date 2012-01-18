package cocoa {
import cocoa.plaf.LookAndFeelProvider;

import flash.display.DisplayObjectContainer;

import net.miginfocom.layout.ContainerWrapper;

public interface RootContentView extends ContentView, ContainerWrapper, LookAndFeelProvider {
  function get displayObject():DisplayObjectContainer;

  function addSubview(view:View):void;

  function set layout(value:MigLayout):void;

  function subviewVisibleChanged():void;
}
}
