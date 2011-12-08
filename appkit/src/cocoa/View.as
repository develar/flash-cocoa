package cocoa {
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;

import net.miginfocom.layout.ComponentWrapper;

public interface View extends ComponentWrapper {
  /**
   * Add view to superview.
   *
   * View should initialize or reinitialize related properties.
   */
  function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void;

  function removeFromSuperview():void;

  function validate():void;

  function get enabled():Boolean;
  function set enabled(value:Boolean):void;

  function set visible(value:Boolean):void;
  
  function setLocation(x:Number, y:Number):void;

  function setSize(w:int, h:int):void;
}
}