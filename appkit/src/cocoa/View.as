package cocoa {
import flash.display.DisplayObject;

import net.miginfocom.layout.ComponentWrapper;

public interface View extends ComponentWrapper {
  /**
   * Add view to superview.
   *
   * View should initialize or reinitialize related properties.
   *
   * @param contentView
   */
  function addToSuperview(superview:ContentView):void;
  function removeFromSuperview(superview:ContentView):void;

  function validate():void;

  function get enabled():Boolean;

  function set visible(value:Boolean):void;
}
}