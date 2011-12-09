package cocoa {
import org.osflash.signals.ISignal;

public interface Viewport extends View {
  function set clipAndEnableScrolling(value:Boolean):void;
  function contentSizeChanged():ISignal;

  function get contentHeight():int;

  function get contentWidth():int;
}
}
