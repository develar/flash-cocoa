package cocoa {
import org.osflash.signals.ISignal;

public interface ListViewMutableDataSource extends ListViewDataSource {
  function get itemAdded():ISignal;
  function get itemRemoved():ISignal;

  function addItem(item:Object):void;

  function addItemAt(item:Object, index:int):void;

  function removeItem(item:Object):void;

  function removeItemAt(index:int):Object;
}
}