package cocoa.tableView {
import cocoa.ListViewDataSource;
import cocoa.RendererManager;

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
}
}
