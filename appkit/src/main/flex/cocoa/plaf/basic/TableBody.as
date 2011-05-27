package cocoa.plaf.basic {
import cocoa.Size;
import cocoa.plaf.LookAndFeel;
import cocoa.tableView.TableColumn;
import cocoa.tableView.TableView;
import cocoa.tableView.TableViewDataSource;
import cocoa.tableView.TextTableColumn;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Shape;
import flash.errors.IllegalOperationError;
import flash.geom.Rectangle;

public class TableBody extends ListBody {
  private var tableView:TableView;
  private var dataSource:TableViewDataSource;
  //noinspection JSFieldCanBeLocal
  private var rowHeight:Number;

  private var background:Shape;
  private var laf:LookAndFeel;

  private var visibleRowCount:int = -1;

  private var oldWidth:Number = 0;
  private var oldHeight:Number = 0;

  public function TableBody(tableView:TableView, laf:LookAndFeel) {
    this.tableView = tableView;
    this.laf = laf;
    this.rowHeight = tableView.rowHeight;
    rowHeightWithSpacing = rowHeight + tableView.intercellSpacing.height;
    dataSource = tableView.dataSource;

    for each (var column:TableColumn in tableView.columns) {
      column.container = this;
    }
  }

  override protected function createChildren():void {
    super.createChildren();

    background = new Shape();
    addDisplayObject(background);
  }

  override protected function measure():void {
    measuredMinHeight = tableView.minRowCount * rowHeightWithSpacing;
    _contentHeight = Math.max(dataSource.rowCount, tableView.minRowCount) * rowHeightWithSpacing;
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

  private function calculateInvisibleLastRowPartBottom(invisibleFirstRowPartTop:Number, h:Number):int {
    const availableSpace:Number = invisibleFirstRowPartTop == 0 ? h : (h - (rowHeightWithSpacing - invisibleFirstRowPartTop));
    const remainderSpace:int = availableSpace % rowHeightWithSpacing;
    return remainderSpace > 0 ? (rowHeightWithSpacing - remainderSpace) : 0;
  }

  override protected function verticalScrollPositionChanged(delta:Number, oldVerticalScrollPosition:Number):void {
    const invisibleFirstRowPartTop:Number = _verticalScrollPosition % rowHeightWithSpacing;
    background.y = _verticalScrollPosition - invisibleFirstRowPartTop - (int(_verticalScrollPosition / rowHeightWithSpacing) % 2 == 0 ? 0 : rowHeightWithSpacing);

    if (oldHeight != height) {
      // updateDisplayList responsible for
      return;
    }

    trace(_verticalScrollPosition);

    const availableSpace:Number = invisibleFirstRowPartTop == 0 ? height : (height - (rowHeightWithSpacing - invisibleFirstRowPartTop));
    var newVisibleRowCount:int = (invisibleFirstRowPartTop > 0 ? 1 : 0) + int(availableSpace / rowHeightWithSpacing);
    if ((availableSpace % rowHeightWithSpacing) > 0) {
      newVisibleRowCount++;
    }

    const oldInvisibleFirstRowPartTop:Number = oldVerticalScrollPosition % rowHeightWithSpacing;
    var removedRowCountDelta:int = (delta + (delta > 0 ? oldInvisibleFirstRowPartTop : -calculateInvisibleLastRowPartBottom(oldInvisibleFirstRowPartTop, height))) / rowHeightWithSpacing;
    if (removedRowCountDelta > visibleRowCount || removedRowCountDelta <= -visibleRowCount) {
      removedRowCountDelta = visibleRowCount;
    }

    const visibleRowCountDelta:int = newVisibleRowCount - visibleRowCount;
    visibleRowCount = newVisibleRowCount;

    adjustRows(removedRowCountDelta, Math.abs(removedRowCountDelta) + visibleRowCountDelta, delta < 0, invisibleFirstRowPartTop);
  }

  private function adjustRows(removedRowCountDelta:int, addedRowCount:int, head:Boolean, invisibleFirstRowPartTop:Number):void {
    var columns:Vector.<TableColumn> = tableView.columns;
    var columnIndex:int;
    if (removedRowCountDelta != 0) {
      for (columnIndex = 0; columnIndex < columns.length; columnIndex++) {
        columns[columnIndex].reuse(removedRowCountDelta, false);
      }
    }

    if (addedRowCount != 0) {
      var endRowIndex:int;
      var startRowIndex:int;
      if (head) {
        startRowIndex = _verticalScrollPosition / rowHeightWithSpacing;
        endRowIndex = startRowIndex + addedRowCount;
        drawCells(_verticalScrollPosition - invisibleFirstRowPartTop, startRowIndex, endRowIndex, head);
      }
      else {
        endRowIndex = _verticalScrollPosition / rowHeightWithSpacing + visibleRowCount;
        startRowIndex = endRowIndex - addedRowCount;
        var relativeRowIndex:int = visibleRowCount - addedRowCount;
        drawCells(_verticalScrollPosition + ((relativeRowIndex - 1) * rowHeightWithSpacing) + rowHeightWithSpacing - invisibleFirstRowPartTop, startRowIndex, endRowIndex, head);
      }
    }
    else if (removedRowCountDelta != 0) {
      for (columnIndex = 0; columnIndex < columns.length; columnIndex++) {
        columns[columnIndex].postLayout();
      }
    }

    cc();
  }

  private function cc():void {
    if (numChildren != (1 + (visibleRowCount * 2))) {
      throw new IllegalOperationError();
    }
    for each (var column:TextTableColumn in tableView.columns) {
      column.cc(visibleRowCount);
    }
  }

  private function calculateMaxVisibleRowCount(h:Number):int {
    var remainder:Number = h % rowHeightWithSpacing;
    // если остаток более 1, значит таблица не содержит всегда константное число видимых строк —
    // если первый занимает мало пикселей и последний занимает мало пикселей (в сумме равное remainder),
    // то текущее число отображаемых строк будет равно максимальному, иначе оно будет на единицу меньше
    return int(h / rowHeightWithSpacing) + (remainder > 1 ? 2 : remainder);
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    if (clipAndEnableScrolling) {
      scrollRect = new Rectangle(horizontalScrollPosition, verticalScrollPosition, w, h);
    }

    if (oldWidth != w) {
      oldWidth = w;
      calculateColumnWidth(w);
    }

    drawBackground(w, calculateMaxVisibleRowCount(h));

    if (oldHeight == h) {
      return;
    }

    oldHeight = h;

    if (visibleRowCount != -1) {
      var head:Boolean;
      if (h == (contentHeight - verticalScrollPosition)) {
        head = true;
      }

      const invisibleFirstRowPartTop:Number = _verticalScrollPosition % rowHeightWithSpacing;
      const availableSpace:Number = invisibleFirstRowPartTop == 0 ? h : (h - (rowHeightWithSpacing - invisibleFirstRowPartTop));
      var newVisibleRowCount:int = (invisibleFirstRowPartTop > 0 ? 1 : 0) + int(availableSpace / rowHeightWithSpacing);
      const remainderSpace:int = availableSpace % rowHeightWithSpacing;
      if (remainderSpace > 0) {
        newVisibleRowCount++;
      }

      const visibleRowCountDelta:int = newVisibleRowCount - visibleRowCount;
      if (visibleRowCountDelta != 0) {
        visibleRowCount = newVisibleRowCount;
        adjustRows(visibleRowCountDelta < 0 ? visibleRowCountDelta : 0, visibleRowCountDelta > 0 ? visibleRowCountDelta : 0, head, invisibleFirstRowPartTop);
      }
    }
    else {
      const startRowIndex:int = _verticalScrollPosition / rowHeightWithSpacing;
      const endRowIndex:int = Math.ceil((h + _verticalScrollPosition) / rowHeightWithSpacing);
      visibleRowCount = endRowIndex - startRowIndex;
      drawCells(_verticalScrollPosition, startRowIndex, endRowIndex, true);
    }
  }

  private function drawCells(startY:Number, startRowIndex:int, endRowIndex:int, head:Boolean):void {
    const intercellSpacing:Size = tableView.intercellSpacing;
    startY += intercellSpacing.height / 2;
    endRowIndex = Math.min(endRowIndex, tableView.dataSource.rowCount);

    const rowHeightWithSpacing:Number = this.rowHeightWithSpacing;
    var columns:Vector.<TableColumn> = tableView.columns;
    var x:Number = 0;
    var y:Number;
    for (var columnIndex:int = 0; columnIndex < columns.length; columnIndex++) {
      var column:TableColumn = columns[columnIndex];
      column.preLayout(head);

      y = startY;
      for (var rowIndex:int = startRowIndex; rowIndex < endRowIndex; rowIndex++) {
        column.createAndLayoutRenderer(rowIndex, x, y);
        y += rowHeightWithSpacing;
      }

      x += column.actualWidth + intercellSpacing.width;
      column.postLayout();
    }
  }

  private function drawBackground(w:Number, maxVisibleRowCount:int):void {
    var g:Graphics = background.graphics;
    g.clear();

    var colors:Vector.<uint> = laf.getColors(tableView.lafKey + ".background");
    var numberOfStripes:int = maxVisibleRowCount + 1;
    var y:Number = 0;
    for (var i:int = 0; i < numberOfStripes; i++) {
      g.beginFill(colors[i % 2 == 0 ? 0 : 1], 1);
      g.drawRect(0, y, w, rowHeightWithSpacing);
      g.endFill();

      y += rowHeightWithSpacing;
    }
  }

  // support only two-columns table where first table column has fixed width and last has remaining width
  private function calculateColumnWidth(w:Number):void {
    var columns:Vector.<TableColumn> = tableView.columns;
    for (var i:int = 0; i < columns.length; i++) {
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
