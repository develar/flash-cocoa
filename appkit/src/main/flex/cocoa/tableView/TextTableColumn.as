package cocoa.tableView {
import cocoa.Insets;
import cocoa.text.TextLineRendererFactory;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.errors.IllegalOperationError;
import flash.text.engine.TextLine;

public class TextTableColumn extends AbstractTableColumn implements TableColumn {
  protected var textLineRendererFactory:TextLineRendererFactory;
  protected var tableView:TableView;
  protected var textInsets:Insets;

  protected const cells:TextLineLinkedList = new TextLineLinkedList();

  protected var previousEntry:TextLineLinkedListEntry;

  public function TextTableColumn(dataField:String, rendererFactory:TextLineRendererFactory, tableView:TableView, textInsets:Insets) {
    super(dataField, rendererFactory);

    textLineRendererFactory = rendererFactory;
    textLineRendererFactory.numberOfUsers++;
    this.tableView = tableView;
    this.textInsets = textInsets;
  }

  protected function createTextLine(rowIndex:int):TextLine {
    return textLineRendererFactory.create(tableView.dataSource.getStringValue(this, rowIndex), actualWidth);
  }

  protected function createEntry(rowIndex:int, x:Number, y:Number):TextLineLinkedListEntry {
    var line:TextLine = createTextLine(rowIndex);
    line.x = x + textInsets.left;
    line.y = y + tableView.rowHeight - textInsets.bottom;
    return TextLineLinkedListEntry.create(line);
  }

  public function createAndLayoutRenderer(rowIndex:int, x:Number, y:Number):DisplayObject {
    var newEntry:TextLineLinkedListEntry = createEntry(rowIndex, x, y);
    if (previousEntry == null) {
      cells.addFirst(newEntry);
    }
    else {
      cells.addAfter(previousEntry, newEntry);
    }

    previousEntry = newEntry;
    return null;
  }

  public function reuse(rowCountDelta:int, finalPass:Boolean):void {
    textLineRendererFactory.reuse(cells, rowCountDelta, finalPass);
  }

  public function preLayout(head:Boolean):void {
    if (!head) {
      previousEntry = cells.tail;
    }
  }

  public function postLayout():void {
    textLineRendererFactory.postLayout();
    previousEntry = null;
  }

  public function set container(container:DisplayObjectContainer):void {
    rendererFactory.container = container;
  }

  public function cc(visibleRowCount:int):void {
    if (cells.size != visibleRowCount) {
      throw new IllegalOperationError();
    }
  }
}
}
