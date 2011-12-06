package cocoa {
import cocoa.plaf.Skin;

public interface SkinnableView extends View, UIPartController {
  /**
   * Префикс, используемый компонентом при составлении абсолютного ключа для получения некого стиля.
   * В самом компоненте указывается путем переопределения геттера defaultLaFPrefix.
   */
  function get lafKey():String;

  function set lafSubkey(value:String):void;

  function get skin():Skin;

  function set skinClass(value:Class):void;
}
}