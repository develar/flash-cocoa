package cocoa.border {
import cocoa.Border;

public interface StatefulBorder extends Border {
  function set stateIndex(value:int):void;

  function hasState(stateIndex:int):Boolean;
}
}