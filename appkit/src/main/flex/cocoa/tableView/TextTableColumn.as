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

  private const cells:TextLineLinkedList = new TextLineLinkedList();

  private var firstInvalidCellEntry:TextLineLinkedListEntry;

  public function TextTableColumn(dataField:String, rendererFactory:TextLineRendererFactory, tableView:TableView, textInsets:Insets) {
    super(dataField, rendererFactory);

    textLineRendererFactory = rendererFactory;
    textLineRendererFactory.numberOfUsers++;
    this.tableView = tableView;
    this.textInsets = textInsets;
  }

  public function createAndLayoutRenderer(rowIndex:int, x:Number, y:Number):DisplayObject {
    var line:TextLine = textLineRendererFactory.create(tableView.dataSource.getStringValue(this, rowIndex));
    if (firstInvalidCellEntry != null) {
      firstInvalidCellEntry.line = line;
      firstInvalidCellEntry = firstInvalidCellEntry.next;
    }
    else {
      cells.addLast(new TextLineLinkedListEntry(line));
    }

    line.x = x + textInsets.left;
    line.y = y + tableView.rowHeight - textInsets.bottom;
    return line;
  }

  public function reuse(rowCountDelta:int, finalPass:Boolean):void {
    textLineRendererFactory.reuse(cells, rowCountDelta, finalPass);
  }

  public function preLayout(relativeStartRowIndex:Number):void {
    if (cells.size == 0 || relativeStartRowIndex == cells.size) {
      return;
    }

    if (relativeStartRowIndex > (cells.size >> 1)) {
      firstInvalidCellEntry = cells.tail;
      var n:int = cells.size - relativeStartRowIndex - 1;
      while (n-- > 0) {
        firstInvalidCellEntry = firstInvalidCellEntry.previous;
      }
    }
    else {
      firstInvalidCellEntry = cells.head;
      while (relativeStartRowIndex-- > 0) {
        firstInvalidCellEntry = firstInvalidCellEntry.next;
      }
    }
  }

  public function postLayout():void {
    textLineRendererFactory.postLayout();
    firstInvalidCellEntry = null;
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
