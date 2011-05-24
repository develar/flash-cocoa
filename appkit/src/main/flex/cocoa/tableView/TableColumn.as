package cocoa.tableView {
import flash.display.DisplayObject;
import flash.errors.IllegalOperationError;

public class TableColumn {
  public function TableColumn(dataField:String, rendererFactory:ListViewRendererFactory) {
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

  public function createAndLayoutRenderer(rowIndex:int, relativeRowIndex:Number, x:Number, y:Number):DisplayObject {
    throw new IllegalOperationError();
  }

  private var _rendererFactory:ListViewRendererFactory;
  public function get rendererFactory():ListViewRendererFactory {
    return _rendererFactory;
  }

  public function layoutRenderer(renderer:DisplayObject, x:Number, y:Number):void {
    
  }

  public function reuse(numberOfRenderers:int):void {

  }

  public function preLayout(numberOfVisibleRows:int):void {
  }

  public function postLayout():void {
  }

  public function moveValidVisibleRenderersByY(numberOfRenderers:int):void {

  }
}
}
