package cocoa.tableView {
import cocoa.AbstractCollectionView;
import cocoa.plaf.LookAndFeel;

public class TableView extends AbstractCollectionView {
  private var _rowHeight:Number;
  public function get rowHeight():Number {
    return _rowHeight;
  }
  public function set rowHeight(value:Number):void {
    _rowHeight = value;
  }

  private var _minRowCount:int = 1;
  public function get minRowCount():int {
    return _minRowCount;
  }
  public function set minRowCount(value:int):void {
    _minRowCount = Math.max(value, 1);
  }

  private var _columns:Vector.<TableColumn>;
  public function get columns():Vector.<TableColumn> {
    return _columns;
  }
  public function set columns(value:Vector.<TableColumn>):void {
    _columns = value;
  }

  private var _dataSource:TableViewDataSource;
  public function get dataSource():TableViewDataSource {
    return _dataSource;
  }
  public function set dataSource(value:TableViewDataSource):void {
    _dataSource = value;
  }

  override protected function get primaryLaFKey():String {
    return "TableView";
  }

  override protected function preSkinCreate(laf:LookAndFeel):void {
    _rowHeight = laf.getInt(lafKey + ".rowHeight");
  }
}
}