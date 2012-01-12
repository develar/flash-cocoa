package cocoa.tableView {
import cocoa.ListViewDataSource;
import cocoa.renderer.RendererManager;

import flash.errors.IllegalOperationError;

import org.osflash.signals.ISignal;

[Abstract]
public class TableColumnImpl implements TableColumn, ListViewDataSource {
  protected var tableView:TableView;

  public function TableColumnImpl(tableView:TableView, dataField:String, rendererManager:RendererManager) {
    this.tableView = tableView;
    _dataField = dataField;
    _rendererManager = rendererManager;
    _rendererManager.dataSource = this;
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

  private var _preferredWidth:int = -1;
  public function get preferredWidth():int {
    return _preferredWidth;
  }

  public function set preferredWidth(value:int):void {
    _preferredWidth = value;
  }

  private var _minWidth:int = 40;
  public function get minWidth():int {
    return _minWidth;
  }

  public function set minWidth(value:int):void {
    _minWidth = value;
  }

  private var _actualWidth:int = -1;
  public function get actualWidth():int {
    return _actualWidth;
  }

  public function set actualWidth(value:int):void {
    _actualWidth = value;
  }

  private var _rendererManager:RendererManager;
  public function get rendererManager():RendererManager {
    return _rendererManager;
  }

  public function get itemCount():int {
    return tableView.dataSource.itemCount;
  }

  public function getObjectValue(itemIndex:int):Object {
    return tableView.dataSource.getObjectValue(this, itemIndex);
  }

  public function getStringValue(itemIndex:int):String {
    return tableView.dataSource.getStringValue(this, itemIndex);
  }

  public function get reset():ISignal {
    throw new IllegalOperationError();
  }

  public function get empty():Boolean {
    return tableView.dataSource.empty;
  }

  public function getItemIndex(object:Object):int {
    throw new IllegalOperationError();
  }
}
}
