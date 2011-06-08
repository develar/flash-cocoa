package cocoa {
import org.osflash.signals.ISignal;

public interface CollectionViewDataSource {
  function getObjectValue(itemIndex:int):Object;
  function getStringValue(itemIndex:int):String;

  function get reset():ISignal;
}
}