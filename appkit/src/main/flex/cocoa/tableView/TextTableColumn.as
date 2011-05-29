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

  public const cells:TextLineLinkedList = new TextLineLinkedList();

  private var previousEntry:TextLineLinkedListEntry;

  public function TextTableColumn(dataField:String, rendererFactory:TextLineRendererFactory, tableView:TableView, textInsets:Insets) {
    super(dataField, rendererFactory);

    textLineRendererFactory = rendererFactory;
    textLineRendererFactory.numberOfUsers++;
    this.tableView = tableView;
    this.textInsets = textInsets;
  }

  public function createAndLayoutRenderer(rowIndex:int, x:Number, y:Number):DisplayObject {
    var line:TextLine = textLineRendererFactory.create(tableView.dataSource.getStringValue(this, rowIndex));
    var newEntry:TextLineLinkedListEntry = cells.create(line);
    if (previousEntry == null) {
      cells.addFirst(newEntry);
    }
    else {
      cells.addAfter(previousEntry, newEntry);
    }

    previousEntry = newEntry;

    line.x = x + textInsets.left;
    line.y = y + tableView.rowHeight - textInsets.bottom;
    return line;
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
