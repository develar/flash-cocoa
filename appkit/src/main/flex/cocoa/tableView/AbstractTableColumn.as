package cocoa.tableView {
[Abstract]
public class AbstractTableColumn {
  public function AbstractTableColumn(dataField:String, rendererFactory:ListViewItemRendererFactory) {
    _dataField = dataField;
    _rendererFactory = rendererFactory;
  }

  private var _dataField:String;
  public function get dataField():String {
    return _dataField;
  }

  public function set dataField(value:String):void {
    _dataField = value;
  }

  private var _title:String;
  public function get title():String {
    return _title;
  }

  public function set title(value:String):void {
    _title = value;
  }

  private var _width:Number;
  public function get width():Number {
    return _width;
  }

  public function set width(value:Number):void {
    _width = value;
  }

  private var _minWidth:Number = 0;
  public function get minWidth():Number {
    return _minWidth;
  }

  public function set minWidth(value:Number):void {
    _minWidth = value;
  }

  private var _actualWidth:Number;
  public function get actualWidth():Number {
    return _actualWidth;
  }

  public function set actualWidth(value:Number):void {
    _actualWidth = value;
  }

  private var _rendererFactory:ListViewItemRendererFactory;
  public function get rendererFactory():ListViewItemRendererFactory {
    return _rendererFactory;
  }
}
}
