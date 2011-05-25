package cocoa.plaf.basic {
import cocoa.Size;
import cocoa.plaf.LookAndFeel;
import cocoa.tableView.TableColumn;
import cocoa.tableView.TableView;
import cocoa.tableView.TableViewDataSource;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Rectangle;

public class TableBody extends ListBody {
  private var tableView:TableView;
  private var dataSource:TableViewDataSource;
  private var rowHeight:Number;

  private var background:Shape;
  private var laf:LookAndFeel;

  private var numberOfVisibleRows:int;

  public function TableBody(tableView:TableView, laf:LookAndFeel) {
    this.tableView = tableView;
    this.laf = laf;
    this.rowHeight = tableView.rowHeight;
    rowHeightWithSpacing = rowHeight + tableView.intercellSpacing.height;
    dataSource = tableView.dataSource;

    for each (var column:TableColumn in tableView.columns) {
      column.rendererFactory.container = this;
    }
  }

  override protected function createChildren():void {
    super.createChildren();

    background = new Shape();
    addDisplayObject(background);
  }

  override protected function measure():void {
    _contentHeight = Math.max(dataSource.numberOfRows, tableView.minNumberOfRows) * rowHeightWithSpacing;
    measuredHeight = _contentHeight;

    var minWidth:Number = 0;
    for each (var column:TableColumn in tableView.columns) {
      minWidth += column.minWidth;
    }

    measuredMinWidth = minWidth + (tableView.columns.length - 1) * tableView.intercellSpacing.width;
    measuredWidth = 0;
  }

  override public function addChild(child:DisplayObject):DisplayObject {
    addDisplayObject(child);
    return child;
  }

  override public function removeChild(child:DisplayObject):DisplayObject {
    removeDisplayObject(child);
    return child;
  }

  override protected function verticalScrollPositionChanged(delta:Number, oldVerticalScrollPosition:Number):void {
    const invisibleFirstRowPartTop:Number = _verticalScrollPosition % rowHeightWithSpacing;
    const invisibleLastRowPartBottom:Number = (numberOfVisibleRows * rowHeightWithSpacing) - height - invisibleFirstRowPartTop;
    var columns:Vector.<TableColumn> = tableView.columns;
    var numberOfRenderers:int = (delta + (delta > 0 ? (oldVerticalScrollPosition % rowHeightWithSpacing) : -invisibleLastRowPartBottom)) / rowHeightWithSpacing;
    if (numberOfRenderers == 0) {
      return;
    }
    
    if (numberOfRenderers > numberOfVisibleRows || numberOfRenderers <= -numberOfVisibleRows) {
      numberOfRenderers = numberOfVisibleRows;
    }

    for (var columnIndex:int = 0; columnIndex < columns.length; columnIndex++) {
      var column:TableColumn = columns[columnIndex];
      column.reuse(numberOfRenderers);
      if (numberOfRenderers != numberOfVisibleRows) {
        column.moveValidVisibleRenderersByY(numberOfRenderers);
      }
    }


    background.y = _verticalScrollPosition - invisibleFirstRowPartTop;
    var bs:Rectangle = background.scrollRect;
    if (int(_verticalScrollPosition / rowHeightWithSpacing) % 2 == 0) {
      if (bs.y != 0) {
        bs.y = 0;
        bs.height -= rowHeightWithSpacing;
        background.scrollRect = bs;
      }
    }
    else if (bs.y == 0) {
      bs.y = rowHeightWithSpacing;
      bs.height += rowHeightWithSpacing;
      background.scrollRect = bs;
    }

    trace(_verticalScrollPosition);
    var endRowIndex:int;
    var startRowIndex:int;
    if (numberOfRenderers > 0) {
      endRowIndex = _verticalScrollPosition / rowHeightWithSpacing + numberOfVisibleRows;
      startRowIndex = endRowIndex - numberOfRenderers;
      var relativeRowIndex:int = numberOfVisibleRows - numberOfRenderers;
      drawCells(_verticalScrollPosition + ((relativeRowIndex - 1) * rowHeightWithSpacing) + rowHeightWithSpacing - invisibleFirstRowPartTop, startRowIndex, endRowIndex, relativeRowIndex);
    }
    else {
      startRowIndex = _verticalScrollPosition / rowHeightWithSpacing;
      endRowIndex = startRowIndex - numberOfRenderers;
      drawCells(_verticalScrollPosition - invisibleFirstRowPartTop, startRowIndex, endRowIndex, 0);
    }
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    if (clipAndEnableScrolling) {
      scrollRect = new Rectangle(horizontalScrollPosition, verticalScrollPosition, w, h);
    }

    calculateColumnWidth(w);

    drawBackground(w, h);

    const rowHeightWithSpacing:Number = this.rowHeightWithSpacing;
    const startRowIndex:int = _verticalScrollPosition / rowHeightWithSpacing;
    const endRowIndex:int = Math.ceil((h + _verticalScrollPosition) / rowHeightWithSpacing);
    numberOfVisibleRows = endRowIndex - startRowIndex;
    drawCells(_verticalScrollPosition, startRowIndex, endRowIndex, 0);
  }

  private function drawCells(startY:Number, startRowIndex:int, endRowIndex:int, startRelativeRowIndex:int):void {
    const intercellSpacing:Size = tableView.intercellSpacing;
    startY += intercellSpacing.height / 2;
    endRowIndex = Math.min(endRowIndex, tableView.dataSource.numberOfRows);

    const rowHeightWithSpacing:Number = this.rowHeightWithSpacing;
    var columns:Vector.<TableColumn> = tableView.columns;
    var x:Number = 0;
    var y:Number;
    for (var columnIndex:int = 0; columnIndex < columns.length; columnIndex++) {
      var column:TableColumn = columns[columnIndex];
      column.preLayout(numberOfVisibleRows);

      y = startY;
      for (var rowIndex:int = startRowIndex, relativeRowIndex:int = startRelativeRowIndex; rowIndex < endRowIndex; rowIndex++, relativeRowIndex++) {
        column.createAndLayoutRenderer(rowIndex, relativeRowIndex, x, y);
        y += rowHeightWithSpacing;
      }

      x += column.actualWidth + intercellSpacing.width;
      column.postLayout();
    }
  }

  private function drawBackground(w:Number, h:Number):void {
    var g:Graphics = background.graphics;
    g.clear();

    var colors:Vector.<uint> = laf.getColors(tableView.lafKey + ".background");
    var numberOfStripes:int = Math.ceil(h / rowHeight) + 1;
    var y:Number = 0;
    for (var i:int = 0; i < numberOfStripes; i++) {
      g.beginFill(colors[i % 2 == 0 ? 0 : 1], 1);
      g.drawRect(0, y, w, rowHeightWithSpacing);
      g.endFill();

      y += rowHeightWithSpacing;
    }

    if (background.scrollRect == null) {
      background.scrollRect = new Rectangle(0, 0, w,  h);
    }
    else {
      background.scrollRect.height = h;
    }
  }

  // support only two-columns table where first table column has fixed width and last has remaining width
  private function calculateColumnWidth(w:Number):void {
    for (var i:int = 0; i < tableView.columns.length; i++) {
      var columns:Vector.<TableColumn> = tableView.columns;
      var column:TableColumn = columns[i];
      var calculatedWidth:Number = column.width;
      if (calculatedWidth != calculatedWidth) {
        column.actualWidth = w - tableView.columns[0].width - tableView.intercellSpacing.width;
      }
      else {
        column.actualWidth = calculatedWidth;
      }
    }
  }
}
}
