package cocoa {
import org.osflash.signals.ISignal;

public interface Viewport extends View {
  function set clipAndEnableScrolling(value:Boolean):void;
  function get contentSizeChanged():ISignal;
  function get scrollPositionReset():ISignal;

  function get contentHeight():int;

  function get contentWidth():int;

  function get verticalScrollPosition():int;

  function set verticalScrollPosition(value:int):void;

  function get horizontalScrollPosition():int;

  function set horizontalScrollPosition(value:int):void;
}
}
