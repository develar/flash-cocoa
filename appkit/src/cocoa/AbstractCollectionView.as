package cocoa {
import org.flyti.plexus.Injectable;

[Abstract]
public class AbstractCollectionView extends AbstractSkinnableView implements Injectable {
  private var _verticalScrollPolicy:int = ScrollPolicy.AUTO;
  public function get verticalScrollPolicy():int {
    return _verticalScrollPolicy;
  }
  public function set verticalScrollPolicy(value:int):void {
    _verticalScrollPolicy = value;
  }

  private var _horizontalScrollPolicy:int = ScrollPolicy.OFF;
  public function get horizontalScrollPolicy():int {
    return _horizontalScrollPolicy;
  }
  public function set horizontalScrollPolicy(value:int):void {
    _horizontalScrollPolicy = value;
  }
}
}
