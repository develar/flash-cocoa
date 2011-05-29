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
import flash.text.engine.TextLine;
import flash.utils.Dictionary;

public class TableBody extends ListBody {
  private var tableView:TableView;
  private var dataSource:TableViewDataSource;
  //noinspection JSFieldCanBeLocal
  private var rowHeight:Number;

  private var background:Shape;
  private var laf:LookAndFeel;

  private var visibleRowCount:int = -1;

  private var oldWidth:Number = 0;

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

    dataSource.reset.add(dataSourceResetHandler);
  }

  private function dataSourceResetHandler():void {
    _verticalScrollPosition = 0;
    _horizontalScrollPosition = 0;
    visibleRowCount = -visibleRowCount - 1;
    invalidateDisplayList();
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

  private function computeInvisibleLastRowPartBottom(invisibleFirstRowPartTop:Number, h:Number):int {
    const availableSpace:Number = invisibleFirstRowPartTop == 0 ? h : (h - (rowHeightWithSpacing - invisibleFirstRowPartTop));
    const remainderSpace:int = availableSpace % rowHeightWithSpacing;
    return remainderSpace > 0 ? (rowHeightWithSpacing - remainderSpace) : 0;
  }

  override protected function verticalScrollPositionChanged(delta:Number, oldVerticalScrollPosition:Number):void {
    const invisibleFirstRowPartTop:Number = _verticalScrollPosition % rowHeightWithSpacing;
    background.y = _verticalScrollPosition - invisibleFirstRowPartTop - (int(_verticalScrollPosition / rowHeightWithSpacing) % 2 == 0 ? 0 : rowHeightWithSpacing);

    if (displayListInvalid) {
      // updateDisplayList responsible for
      return;
    }

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

    //cc();
  }

  //noinspection JSUnusedLocalSymbols
  private function cc():void {
    if (numChildren != (1 + (visibleRowCount * tableView.columns.length))) {
      throw new IllegalOperationError();
    }
    for each (var column:TextTableColumn in tableView.columns) {
      column.cc(visibleRowCount);
    }

    var i:int = numChildren - 1;
    var map:Dictionary = new Dictionary();
    while (i > 0) {
      var line:TextLine = getChildAt(i--) as TextLine;
      if (line == null) {
        continue;
      }

      var xx:Vector.<Number> = map[line.y];
      if (xx == null) {
        xx = new Vector.<Number>(1);
        xx[0] = line.x;
        map[line.y] = xx;
      }
      else if (xx.length > 1) {
        throw new IllegalOperationError();
      }
      else {
        xx[1] = line.x;
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

  override protected function updateDisplayList(w:Number, h:Number):void {
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
        const endRowIndex:int = Math.min(computeEndIndex(h, _verticalScrollPosition), tableView.dataSource.rowCount);
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
    if (visibleRowCount != -1) {
      var columns:Vector.<TableColumn> = tableView.columns;
      for (var columnIndex:int = 0; columnIndex < columns.length; columnIndex++) {
        columns[columnIndex].reuse(visibleRowCount + 1, false);
      }
    }

    const startRowIndex:int = _verticalScrollPosition / rowHeightWithSpacing;
    const endRowIndex:int = Math.min(computeEndIndex(h, _verticalScrollPosition), tableView.dataSource.rowCount);
    visibleRowCount = endRowIndex - startRowIndex;
    drawCells(_verticalScrollPosition, startRowIndex, endRowIndex, true);
  }

  private function computeEndIndex(h:Number, verticalScrollPosition:Number):Number {
    return Math.ceil((h + verticalScrollPosition) / rowHeightWithSpacing);
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
        column.actualWidth = w - tableView.columns[0].width - tableView.intercellSpacing.width;
      }
      else {
        column.actualWidth = calculatedWidth;
      }
    }
  }
}
}
