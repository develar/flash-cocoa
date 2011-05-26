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
  private var rowHeight:Number;

  private var background:Shape;
  private var laf:LookAndFeel;

  private var visibleRowCount:int = -1;
  private var maxVisibleRowCount:int = -1;

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

  override protected function verticalScrollPositionChanged(delta:Number, oldVerticalScrollPosition:Number):void {
    const invisibleFirstRowPartTop:Number = _verticalScrollPosition % rowHeightWithSpacing;
    var availableSpace:Number = invisibleFirstRowPartTop == 0 ? height : (height - (rowHeightWithSpacing - invisibleFirstRowPartTop));
    var newVisibleRowCount:int = (invisibleFirstRowPartTop > 0 ? 1 : 0) + int(availableSpace / rowHeightWithSpacing);
    var remainderSpace:int = availableSpace % rowHeightWithSpacing;
    var invisibleLastRowPartBottom:Number = 0;
    if (remainderSpace > 0) {
      newVisibleRowCount++;
      invisibleLastRowPartBottom = rowHeightWithSpacing - remainderSpace;
    }

    var columns:Vector.<TableColumn> = tableView.columns;
    var rowCountDelta:int = (delta + (delta > 0 ? (oldVerticalScrollPosition % rowHeightWithSpacing) : -invisibleLastRowPartBottom)) / rowHeightWithSpacing;
    if (rowCountDelta > visibleRowCount || rowCountDelta <= -visibleRowCount) {
      rowCountDelta = visibleRowCount;
    }

    trace(_verticalScrollPosition);

    if (rowCountDelta != 0) {
      background.y = _verticalScrollPosition - invisibleFirstRowPartTop;

      var needMoveValidVisibleRenders:Boolean = rowCountDelta != maxVisibleRowCount;
      var effectiveRowCountDelta:int = rowCountDelta;
      if (needMoveValidVisibleRenders && rowCountDelta < 0 && maxVisibleRowCount != newVisibleRowCount) {
        effectiveRowCountDelta++;
        if (effectiveRowCountDelta == 0) {
          needMoveValidVisibleRenders = false;
        }
      }

      for (var columnIndex:int = 0; columnIndex < columns.length; columnIndex++) {
        var column:TableColumn = columns[columnIndex];
        column.reuse(rowCountDelta, visibleRowCount, false);
        if (needMoveValidVisibleRenders) {
          column.moveValidVisibleRenderersByY(effectiveRowCountDelta, visibleRowCount);
        }
      }
    }

    var endRowIndex:int;
    var startRowIndex:int;
    if (rowCountDelta < 0) {
      rowCountDelta -= newVisibleRowCount - visibleRowCount;
      if (rowCountDelta != 0) {
        startRowIndex = _verticalScrollPosition / rowHeightWithSpacing;
        endRowIndex = startRowIndex - rowCountDelta;
        drawCells(_verticalScrollPosition - invisibleFirstRowPartTop, startRowIndex, endRowIndex, 0);
      }
      clearLastRenderer(newVisibleRowCount, columns, rowCountDelta == 0);
    }
    else {
      rowCountDelta += newVisibleRowCount - visibleRowCount;
      endRowIndex = _verticalScrollPosition / rowHeightWithSpacing + newVisibleRowCount;
      if (rowCountDelta > 0) {
        startRowIndex = endRowIndex - rowCountDelta;
      }
      else if (newVisibleRowCount == visibleRowCount) {
        cc();
        return;
      }

      clearLastRenderer(newVisibleRowCount, columns, false);

      startRowIndex = endRowIndex - rowCountDelta;
      var relativeRowIndex:int = visibleRowCount - rowCountDelta;
      drawCells(_verticalScrollPosition + ((relativeRowIndex - 1) * rowHeightWithSpacing) + rowHeightWithSpacing - invisibleFirstRowPartTop, startRowIndex, endRowIndex, relativeRowIndex);
    }

    cc();
  }

  private function clearLastRenderer(newVisibleRowCount:int, columns:Vector.<TableColumn>, callPostLayout:Boolean):void {
    if (newVisibleRowCount != visibleRowCount) {
      visibleRowCount = newVisibleRowCount;
      for (var j:int = 0; j < columns.length; j++) {
        var column:TableColumn = columns[j];
        column.clearLastRenderer();
        if (callPostLayout) {
          column.postLayout();
        }
      }
    }
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

    const newMaxVisibleRowCount:int = calculateMaxVisibleRowCount(h);
    const drawn:Boolean = maxVisibleRowCount != -1;
    var numberOfRowsDelta:int = drawn ? newMaxVisibleRowCount - maxVisibleRowCount : 1;

    maxVisibleRowCount = newMaxVisibleRowCount;

    drawBackground(w);

    if (oldHeight == h) {
      return;
    }

    oldHeight = h;

    if (numberOfRowsDelta == 0) {
      return;
    }

    const startRowIndex:int = _verticalScrollPosition / rowHeightWithSpacing;
    const endRowIndex:int = Math.ceil((h + _verticalScrollPosition) / rowHeightWithSpacing);
    visibleRowCount = endRowIndex - startRowIndex;

    var columns:Vector.<TableColumn> = tableView.columns;
    var i:int;
    if (numberOfRowsDelta < 0) {
      for (i = 0; i < columns.length; i++) {
        var column:TableColumn = columns[i];
        column.reuse(numberOfRowsDelta, visibleRowCount, true);
        column.maxVisibleRowCountChanged(maxVisibleRowCount);
      }
    }
    else if (drawn) {
      drawCells(_verticalScrollPosition, endRowIndex - numberOfRowsDelta, endRowIndex, maxVisibleRowCount - numberOfRowsDelta, true);
    }
    else {
      drawCells(_verticalScrollPosition, startRowIndex, endRowIndex, 0, true);
    }
  }

  private function drawCells(startY:Number, startRowIndex:int, endRowIndex:int, startRelativeRowIndex:int, numberOfVisibleRowsChanged:Boolean = false):void {
    const intercellSpacing:Size = tableView.intercellSpacing;
    startY += intercellSpacing.height / 2;
    endRowIndex = Math.min(endRowIndex, tableView.dataSource.rowCount);

    const rowHeightWithSpacing:Number = this.rowHeightWithSpacing;
    var columns:Vector.<TableColumn> = tableView.columns;
    var x:Number = 0;
    var y:Number;
    for (var columnIndex:int = 0; columnIndex < columns.length; columnIndex++) {
      var column:TableColumn = columns[columnIndex];

      if (numberOfVisibleRowsChanged) {
        column.maxVisibleRowCountChanged(maxVisibleRowCount);
      }

      y = startY;
      for (var rowIndex:int = startRowIndex, relativeRowIndex:int = startRelativeRowIndex; rowIndex < endRowIndex; rowIndex++, relativeRowIndex++) {
        column.createAndLayoutRenderer(rowIndex, relativeRowIndex, x, y);
        y += rowHeightWithSpacing;
      }

      x += column.actualWidth + intercellSpacing.width;
      column.postLayout();
    }
  }

  private function drawBackground(w:Number):void {
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
