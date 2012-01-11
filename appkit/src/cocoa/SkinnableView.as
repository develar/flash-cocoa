package cocoa {
import cocoa.plaf.Skin;

public interface SkinnableView extends View, UIPartController {
  /** Prefix, component use it for compute absolute LaF Key to retrieve some style.
   * Component specify it via override defaultLaFPrefix getter @see AbstractSkinnableView#primaryLaFKey
   */
  function get lafKey():String;

  function set lafSubkey(value:String):void;

  function get skin():Skin;

  function set skinClass(value:Class):void;
}
}