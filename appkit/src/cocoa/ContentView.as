package cocoa {
import cocoa.plaf.LookAndFeelProvider;

import flash.display.DisplayObjectContainer;

public interface ContentView extends View, LookAndFeelProvider {
  function get displayObject():DisplayObjectContainer;

  function invalidateSubview(invalidateSuperview:Boolean = true):void;
}
}