package cocoa {
import net.miginfocom.layout.ComponentWrapper;

public interface View extends ComponentWrapper {
  /**
   * Add view to superview.
   *
   * View should initialize or reinitialize related properties.
   *
   * @param superview
   */
  function addToSuperview(superview:ContentView):void;
  function removeFromSuperview():void;

  function validate():void;

  function get enabled():Boolean;
  function set enabled(value:Boolean):void;

  function set visible(value:Boolean):void;
  
  function setLocation(x:Number, y:Number):void;

  function setSize(w:int, h:int):void;
}
}