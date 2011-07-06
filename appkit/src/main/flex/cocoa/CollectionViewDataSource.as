package cocoa {
import org.osflash.signals.ISignal;

public interface CollectionViewDataSource {
  function get itemCount():int;
  function get reset():ISignal;

  function get empty():Boolean;
}
}
