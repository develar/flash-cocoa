package cocoa {
import org.flyti.util.List;

public interface DataControl extends Control {
  function get items():List;
  function set items(value:List):void;

  function get selectedIndex():int;
  function set selectedIndex(value:int):void;
}
}