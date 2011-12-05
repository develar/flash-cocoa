package cocoa {
import cocoa.plaf.LookAndFeelProvider;

import flash.display.DisplayObject;

public interface ContentView extends View, LookAndFeelProvider {
  function set preferredWidth(value:int):void;

  function set preferredHeight(value:int):void;

  function get displayObject():DisplayObject;
}
}