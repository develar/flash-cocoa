package cocoa.plaf.basic {
import cocoa.AbstractView;
import cocoa.tableView.TableColumn;
import cocoa.tableView.TableView;
import cocoa.tableView.TableViewDataSource;

import flash.display.DisplayObject;

import spark.core.IViewport;

public class TableBody extends AbstractView implements IViewport {
  private var tableView:TableView;
  private var dataSource:TableViewDataSource;
  private var rowHeight:Number;

  public function TableBody(tableView:TableView) {
    this.tableView = tableView;
    this.rowHeight = tableView.rowHeight;
    dataSource = tableView.dataSource;

    for each (var column:TableColumn in tableView.columns) {
      column.rendererFactory.container = this;
    }
  }

  public function get contentWidth():Number {
    return 0;
  }

  private var _contentHeight:Number;
  public function get contentHeight():Number {
    return _contentHeight;
  }

  public function get horizontalScrollPosition():Number {
    return 0;
  }

  public function set horizontalScrollPosition(value:Number):void {
  }

  public function get verticalScrollPosition():Number {
    return 0;
  }

  public function set verticalScrollPosition(value:Number):void {
  }

  public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number {
    return 0;
  }

  public function getVerticalScrollPositionDelta(navigationUnit:uint):Number {
    return 0;
  }

  public function get clipAndEnableScrolling():Boolean {
    return true;
  }

  public function set clipAndEnableScrolling(value:Boolean):void {
  }

  override protected function measure():void {
    _contentHeight = dataSource.numberOfRows * rowHeight;
    measuredHeight = _contentHeight;

    var minWidth:Number = 0;
    for each (var column:TableColumn in tableView.columns) {
      minWidth += column.minWidth;
    }

    measuredMinWidth = minWidth;
    measuredWidth = 0;
  }

  override public function addChild(child:DisplayObject):DisplayObject {
    addDisplayObject(child);
    return child;
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    calculateColumnWidth(w);

    var startRowIndex:int = 0;
    var endRowIndex:int = h / rowHeight;
    //noinspection JSMismatchedCollectionQueryUpdate
    var columns:Vector.<TableColumn> = tableView.columns;
    var y:Number = 0;
    for (var rowIndex:int = startRowIndex; rowIndex < endRowIndex; rowIndex++) {
      var x:Number = 0;
      for (var columnIndex:int = 0; columnIndex < columns.length; columnIndex++) {
        var column:TableColumn = columns[columnIndex];
        column.createAndLayoutRenderer(rowIndex, x,  y);
        x += column.actualWidth;
      }

      y += rowHeight;
    }
  }

  // support only two-columns table where first table column has fixed width and last has remaining width
  private function calculateColumnWidth(w:Number):void {
    for (var i:int = 0; i < tableView.columns.length; i++) {
      var columns:Vector.<TableColumn> = tableView.columns;
      var column:TableColumn = columns[i];
      var calculatedWidth:Number = column.width;
      if (calculatedWidth != calculatedWidth) {
        column.actualWidth = w - tableView.columns[0].width;
      }
      else {
        column.actualWidth = calculatedWidth;
      }
    }
  }
}
}
