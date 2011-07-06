package cocoa {
import cocoa.layout.CollectionLayout;

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

  private var _layout:CollectionLayout;
  public function get layout():CollectionLayout {
    return _layout;
  }
  public function set layout(value:CollectionLayout):void {
    _layout = value;
  }
}
}
