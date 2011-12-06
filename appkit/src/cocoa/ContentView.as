package cocoa {
import cocoa.plaf.LookAndFeelProvider;

import flash.display.DisplayObjectContainer;

public interface ContentView extends View, LookAndFeelProvider {
  function set preferredWidth(value:int):void;

  function set preferredHeight(value:int):void;

  function get displayObject():DisplayObjectContainer;

  function invalidateSubview(invalidateSuperview:Boolean = true):void;
}
}