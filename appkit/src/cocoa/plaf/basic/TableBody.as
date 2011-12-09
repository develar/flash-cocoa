package cocoa.plaf.basic {
import cocoa.CollectionBody;
import cocoa.ContentView;
import cocoa.plaf.LookAndFeel;
import cocoa.tableView.TableColumn;
import cocoa.tableView.TableView;
import cocoa.tableView.TableViewDataSource;

import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Point;
import flash.geom.Rectangle;

public class TableBody extends CollectionBody {
  private var tableView:TableView;
  private var dataSource:TableViewDataSource;
  //noinspection JSFieldCanBeLocal
  private var rowHeight:Number;

  private var background:Shape;
  private var laf:LookAndFeel;

  private var visibleRowCount:int = -1;

  private var oldWidth:Number = 0;

  private var intercellSpacing:Point;

  public function TableBody(tableView:TableView, laf:LookAndFeel) {
    this.tableView = tableView;
    this.laf = laf;
    this.rowHeight = tableView.rowHeight;
    intercellSpacing = laf.getPoint(tableView.lafKey + ".intercellSpacing");
    rowHeightWithSpacing = rowHeight + intercellSpacing.y;
    dataSource = tableView.dataSource;

    for each (var column:TableColumn in tableView.columns) {
      column.rendererManager.container = this;
    }
  }

  override public function addToSuperview(displayObjectContainer:DisplayObjectContainer, laf:LookAndFeel, superview:ContentView = null):void {
    super.addToSuperview(displayObjectContainer, laf, superview);

    background = new Shape();
    addChild(background);

    dataSource.reset.add(dataSourceResetHandler);
  }

  private function dataSourceResetHandler():void {
    _verticalScrollPosition = 0;
    _horizontalScrollPosition = 0;
    background.y = 0;
    //dispatchPropertyChangeEvent("verticalScrollPosition", -1, 0);
    //dispatchPropertyChangeEvent("horizontalScrollPosition", -1, 0);
    if (visibleRowCount != -1) {
      visibleRowCount = -visibleRowCount - 1;
    }

    invalidate();
  }

  override public function getMinimumHeight(wHint:int = -1):int {
    return tableView.minRowCount * rowHeightWithSpacing;
  }

  override public function getMinimumWidth(hHint:int = -1):int {
    var minWidth:Number = 0;
    for each (var column:TableColumn in tableView.columns) {
      minWidth += column.minWidth;
    }

    return minWidth + (tableView.columns.length - 1) * intercellSpacing.x;
  }

  override public function getPreferredWidth(hHint:int = -1):int {
    return super.getPreferredWidth(hHint);
  }

  override public function getPreferredHeight(wHint:int = -1):int {
    return Math.max(dataSource.itemCount, tableView.minRowCount) * rowHeightWithSpacing;
  }

   protected function measure():void {
    _contentHeight = Math.max(dataSource.itemCount, tableView.minRowCount) * rowHeightWithSpacing;
    //dispatchPropertyChangeEvent("contentHeight", -1, _contentHeight);
    //measuredHeight = _contentHeight;

    var minWidth:Number = 0;
    for each (var column:TableColumn in tableView.columns) {
      minWidth += column.minWidth;
    }

    //measuredWidth = 0;
  }

  private function computeInvisibleLastRowPartBottom(invisibleFirstRowPartTop:Number, h:Number):int {
    const availableSpace:Number = invisibleFirstRowPartTop == 0 ? h : (h - (rowHeightWithSpacing - invisibleFirstRowPartTop));
    const remainderSpace:int = availableSpace % rowHeightWithSpacing;
    return remainderSpace > 0 ? (rowHeightWithSpacing - remainderSpace) : 0;
  }

  override protected function verticalScrollPositionChanged(delta:Number, oldVerticalScrollPosition:Number):void {
    const invisibleFirstRowPartTop:Number = _verticalScrollPosition % rowHeightWithSpacing;
    background.y = _verticalScrollPosition - invisibleFirstRowPartTop - (int(_verticalScrollPosition / rowHeightWithSpacing) % 2 == 0 ? 0 : rowHeightWithSpacing);

    //if (displayListInvalid) {
      // updateDisplayList responsible for
      //return;
    //}

    const availableSpace:Number = invisibleFirstRowPartTop == 0 ? height : (height - (rowHeightWithSpacing - invisibleFirstRowPartTop));
    var newVisibleRowCount:int = (invisibleFirstRowPartTop > 0 ? 1 : 0) + int(availableSpace / rowHeightWithSpacing);
    if ((availableSpace % rowHeightWithSpacing) > 0) {
      newVisibleRowCount++;
    }

    const oldInvisibleFirstRowPartTop:Number = oldVerticalScrollPosition % rowHeightWithSpacing;
    var removedRowCountDelta:int = (delta + (delta > 0 ? oldInvisibleFirstRowPartTop : -computeInvisibleLastRowPartBottom(oldInvisibleFirstRowPartTop, height))) / rowHeightWithSpacing;
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
        columns[columnIndex].rendererManager.reuse(removedRowCountDelta, false);
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
        columns[columnIndex].rendererManager.postLayout();
      }
    }
  }

  private function computeMaxVisibleRowCount(h:Number):int {
    var remainder:Number = h % rowHeightWithSpacing;
    // если остаток более 1, значит таблица не содержит всегда константное число видимых строк —
    // если первый занимает мало пикселей и последний занимает мало пикселей (в сумме равное remainder),
    // то текущее число отображаемых строк будет равно максимальному, иначе оно будет на единицу меньше
    return int(h / rowHeightWithSpacing) + (remainder > 1 ? 2 : remainder);
  }

  override protected function draw(w:int, h:int):void {
    var s:Rectangle = scrollRect;
    var oldVerticalScrollPosition:Number = s == null ? 0 : s.y;
    if (clipAndEnableScrolling) {
      scrollRect = new Rectangle(horizontalScrollPosition, verticalScrollPosition, w, h);
    }

    if (oldWidth != w) {
      oldWidth = w;
      calculateColumnWidth(w);
    }

    drawBackground(w, computeMaxVisibleRowCount(h));

    if (visibleRowCount > -1) {
      if (oldHeight == h) {
        return;
      }

      const invisibleFirstRowPartTop:Number = _verticalScrollPosition % rowHeightWithSpacing;

      const availableSpace:Number = invisibleFirstRowPartTop == 0 ? h : (h - (rowHeightWithSpacing - invisibleFirstRowPartTop));
      var newVisibleRowCount:int = (invisibleFirstRowPartTop > 0 ? 1 : 0) + int(availableSpace / rowHeightWithSpacing);
      const remainderSpace:int = availableSpace % rowHeightWithSpacing;
      if (remainderSpace > 0) {
        newVisibleRowCount++;
      }

      const visibleRowCountDelta:int = newVisibleRowCount - visibleRowCount;
      if (visibleRowCountDelta == 0) {
        oldHeight = h;
        return;
      }

      visibleRowCount = newVisibleRowCount;
      // если высота увеличилась и при этом мы достигли конца данных (то есть больше нет строк для отображения вниз (verticalScrollPosition установлен в максимум, а максимум это наш contentHeight - height)),
      // то мы должны добавить строки как в конец (должны проверить остаток неотображенных строк в конце), так и в начало
      if ((h - oldHeight) > 0 && h == (contentHeight - verticalScrollPosition)) {
        const startRowIndex:int = oldVerticalScrollPosition / rowHeightWithSpacing + (visibleRowCount - visibleRowCountDelta);
        const endRowIndex:int = Math.min(computeEndIndex(h, _verticalScrollPosition), tableView.dataSource.itemCount);
        const addedToTailRowCount:int = endRowIndex - startRowIndex;
        if (addedToTailRowCount != 0) {
          var relativeRowIndex:int = visibleRowCount - addedToTailRowCount;
          drawCells(_verticalScrollPosition + ((relativeRowIndex - 1) * rowHeightWithSpacing) + rowHeightWithSpacing - invisibleFirstRowPartTop, startRowIndex, endRowIndex, false);
        }

        const addedToHeadRowCount:int = visibleRowCountDelta - addedToTailRowCount;
        if (addedToHeadRowCount != 0) {
          adjustRows(0, addedToHeadRowCount, true, invisibleFirstRowPartTop);
        }
      }
      else {
        adjustRows(visibleRowCountDelta < 0 ? visibleRowCountDelta : 0, visibleRowCountDelta > 0 ? visibleRowCountDelta : 0, false, invisibleFirstRowPartTop);
      }
    }
    else {
      initialDrawCells(h);
    }

    oldHeight = h;
  }

  private function initialDrawCells(h:Number):void {
    const startRowIndex:int = _verticalScrollPosition / rowHeightWithSpacing;
    const endRowIndex:int = Math.min(computeEndIndex(h, _verticalScrollPosition), tableView.dataSource.itemCount);
    var newVisibleRowCount:int = endRowIndex - startRowIndex;

    if (visibleRowCount != -1) {
      var columns:Vector.<TableColumn> = tableView.columns;
      for (var columnIndex:int = 0; columnIndex < columns.length; columnIndex++) {
        columns[columnIndex].rendererManager.reuse(visibleRowCount + 1, newVisibleRowCount == 0);
      }
    }

    if (newVisibleRowCount != 0) {
      visibleRowCount = newVisibleRowCount;
      drawCells(_verticalScrollPosition, startRowIndex, endRowIndex, true);
    }
    else {
      visibleRowCount = -1;
    }
  }

  private function computeEndIndex(h:Number, verticalScrollPosition:Number):Number {
    return Math.ceil((h + verticalScrollPosition) / rowHeightWithSpacing);
  }

  private function drawCells(startY:Number, startRowIndex:int, endRowIndex:int, head:Boolean):void {
    startY += intercellSpacing.y / 2;
    endRowIndex = Math.min(endRowIndex, tableView.dataSource.itemCount);

    var columns:Vector.<TableColumn> = tableView.columns;
    var x:Number = 0;
    var y:Number;
    const lastColumnIndex:int = columns.length - 1;
    for (var columnIndex:int = 0; columnIndex < columns.length; columnIndex++) {
      var column:TableColumn = columns[columnIndex];
      column.rendererManager.preLayout(head);

      y = startY;
      for (var rowIndex:int = startRowIndex; rowIndex < endRowIndex; rowIndex++) {
        column.rendererManager.createAndLayoutRenderer(rowIndex, x, y, column.actualWidth, tableView.rowHeight);
        y += rowHeightWithSpacing;
      }

      x += column.actualWidth + intercellSpacing.x;
      column.rendererManager.postLayout(columnIndex == lastColumnIndex);
    }
  }

  private function drawBackground(w:Number, maxVisibleRowCount:int):void {
    var g:Graphics = background.graphics;
    g.clear();

    var colors:Vector.<uint> = laf.getColors(tableView.lafKey + ".bg");
    var stripeCount:int = maxVisibleRowCount + 1;
    var y:Number = 0;
    for (var i:int = 0; i < stripeCount; i++) {
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
        column.actualWidth = w - tableView.columns[0].width - intercellSpacing.x;
      }
      else {
        column.actualWidth = calculatedWidth;
      }
    }
  }

  public function getColumnIndexAt(x:Number):int {
    var sx:Number = x;
    var columns:Vector.<TableColumn> = tableView.columns;
    for (var i:int = 0; i < columns.length; i++) {
      var column:TableColumn = columns[i];
      if (sx <= column.actualWidth) {
        return i;
      }

      sx -= column.actualWidth + intercellSpacing.x;
    }

    return -1;
  }

  public function getRowIndexAt(y:Number):int {
    return Math.ceil(y / rowHeightWithSpacing) - 1;
  }
}
}
