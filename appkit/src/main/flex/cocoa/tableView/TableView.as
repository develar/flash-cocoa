package cocoa.tableView {
import cocoa.AbstractComponent;
import cocoa.ScrollPolicy;
import cocoa.Size;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;

public class TableView extends AbstractComponent {
  private var _rowHeight:Number;
  public function get rowHeight():Number {
    return _rowHeight;
  }
  public function set rowHeight(value:Number):void {
    _rowHeight = value;
  }

  private var _minNumberOfRows:int;
  public function get minNumberOfRows():int {
    return _minNumberOfRows;
  }
  public function set minNumberOfRows(value:int):void {
    _minNumberOfRows = value;
  }

  /**
   * height must be even
   */
  private var _intercellSpacing:Size;
  public function get intercellSpacing():Size {
    return _intercellSpacing;
  }
  public function set intercellSpacing(value:Size):void {
    _intercellSpacing = value;
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

  override protected function get primaryLaFKey():String {
    return "TableView";
  }

  override public function createView(laf:LookAndFeel):Skin {
    _rowHeight = laf.getInt(lafKey + ".rowHeight");
    _intercellSpacing = Size(laf.getObject(lafKey + ".intercellSpacing"));

    return super.createView(laf);
  }
}
}