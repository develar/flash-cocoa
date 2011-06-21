package cocoa.tableView {
import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

public class AbstractCollectionViewDataSource {
  protected var sourceItemCounter:int = 0;

  public function get itemCount():int {
    return sourceItemCounter;
  }

  protected var _reset:ISignal;
  public function get reset():ISignal {
    if (_reset == null) {
      _reset = new Signal();
    }
    return _reset;
  }
}
}
