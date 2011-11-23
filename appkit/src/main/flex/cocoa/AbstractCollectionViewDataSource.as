package cocoa {
import flash.errors.IllegalOperationError;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

[Abstract]
public class AbstractCollectionViewDataSource {
  protected var _itemCount:int = 0;
  public function get itemCount():int {
    return _itemCount;
  }

  public function get empty():Boolean {
    return itemCount == 0;
  }

  protected var _reset:ISignal;
  public function get reset():ISignal {
    if (_reset == null) {
      _reset = new Signal();
    }
    return _reset;
  }

  protected var _itemAdded:ISignal;
  public function get itemAdded():ISignal {
    if (_itemAdded == null) {
      _itemAdded = new Signal();
    }
    return _itemAdded;
  }

  protected var _itemRemoved:ISignal;
  public function get itemRemoved():ISignal {
    if (_itemRemoved == null) {
      _itemRemoved = new Signal();
    }
    return _itemRemoved;
  }

  public function addItem(item:Object):void {
    addItemAt(item, itemCount);
  }

  public function addItemAt(item:Object, index:int):void {
    throw new IllegalOperationError();
  }
}
}
