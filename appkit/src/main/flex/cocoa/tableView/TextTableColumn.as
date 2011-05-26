package cocoa.tableView {
import cocoa.Insets;
import cocoa.text.TextLineRendererFactory;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.errors.IllegalOperationError;
import flash.text.engine.TextLine;

public class TextTableColumn extends AbstractTableColumn implements TableColumn {
  private var textLineRendererFactory:TextLineRendererFactory;
  private var tableView:TableView;
  private var textInsets:Insets;

  private const visibleRenderers:Vector.<TextLine> = new Vector.<TextLine>();

  public function TextTableColumn(dataField:String, rendererFactory:TextLineRendererFactory, tableView:TableView, textInsets:Insets) {
    super(dataField, rendererFactory);

    textLineRendererFactory = rendererFactory;
    textLineRendererFactory.numberOfUsers++;
    this.tableView = tableView;
    this.textInsets = textInsets;
  }

  public function createAndLayoutRenderer(rowIndex:int, relativeRowIndex:Number, x:Number, y:Number):DisplayObject {
    var line:TextLine = textLineRendererFactory.create(tableView.dataSource.getStringValue(this, rowIndex));
    visibleRenderers[relativeRowIndex] = line;

    line.x = x + textInsets.left;
    line.y = y + tableView.rowHeight - textInsets.bottom;
    return line;
  }

  public function cc(visibleRowCount:int):void {
    for each (var textLine:TextLine in visibleRenderers) {
      if (visibleRenderers.indexOf(textLine) != visibleRenderers.lastIndexOf(textLine)) {
        throw new IllegalOperationError();
      }
    }

    if (visibleRenderers[visibleRowCount - 1] == null) {
      throw new IllegalOperationError();
    }
  }

  public function reuse(rowCountDelta:int, visibleRowCount:int, finalPass:Boolean):void {
    textLineRendererFactory.reuse(visibleRenderers, rowCountDelta, visibleRowCount, finalPass);
  }

  public function moveValidVisibleRenderersByY(rowCountDelta:int, visibleRowCount:int):void {
    var i:int;
    if (rowCountDelta > 0) {
      for (i = rowCountDelta; i < visibleRowCount; i++) {
        visibleRenderers[i - rowCountDelta] = visibleRenderers[i];
      }
    }
    else {
      for (i = visibleRowCount + rowCountDelta - 1; i >= 0; i--) {
        visibleRenderers[i - rowCountDelta] = visibleRenderers[i];
      }
    }
  }

  public function postLayout():void {
    textLineRendererFactory.postLayout();
  }

  public function maxVisibleRowCountChanged(maxVisibleRowCount:int):void {
    visibleRenderers.fixed = false;
    visibleRenderers.length = maxVisibleRowCount;
    visibleRenderers.fixed = true;
  }

  public function set container(container:DisplayObjectContainer):void {
    rendererFactory.container = container;
  }

  public function clearLastRenderer():void {
    visibleRenderers[visibleRenderers.length - 1] = null;
  }
}
}