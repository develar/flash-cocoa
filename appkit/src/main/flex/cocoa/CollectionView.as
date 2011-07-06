package cocoa {
import cocoa.layout.Layout;

public class CollectionView extends AbstractCollectionView {
  private var _dataSource:ListViewDataSource;
  public function get dataSource():ListViewDataSource {
    return _dataSource;
  }
  public function set dataSource(value:ListViewDataSource):void {
    _dataSource = value;
  }

  override protected function get primaryLaFKey():String {
    return "CollectionView";
  }

  private var _layout:Layout;
  public function get layout():Layout {
    return _layout;
  }
  public function set layout(value:Layout):void {
    _layout = value;
  }
}
}
