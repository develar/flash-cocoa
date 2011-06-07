package cocoa {
public class CollectionView extends AbstractCollectionView {
  private var _dataSource:CollectionViewDataSource;
  public function get dataSource():CollectionViewDataSource {
    return _dataSource;
  }
  public function set dataSource(value:CollectionViewDataSource):void {
    _dataSource = value;
  }

  override protected function get primaryLaFKey():String {
    return "CollectionView";
  }
}
}
