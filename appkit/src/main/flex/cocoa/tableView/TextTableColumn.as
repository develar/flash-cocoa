package cocoa.tableView {
import cocoa.Insets;
import cocoa.text.TextLineRendererFactory;

import flash.display.DisplayObject;
import flash.text.engine.TextLine;

public class TextTableColumn extends TableColumn {
  private var textLineRendererFactory:TextLineRendererFactory;
  private var tableView:TableView;
  private var textInsets:Insets;

  public function TextTableColumn(dataField:String, rendererFactory:TextLineRendererFactory, tableView:TableView, textInsets:Insets) {
    super(dataField, rendererFactory);

    textLineRendererFactory = rendererFactory;
    this.tableView = tableView;
    this.textInsets = textInsets;
  }

  override public function createAndLayoutRenderer(rowIndex:int, x:Number, y:Number):DisplayObject {
    var line:TextLine = textLineRendererFactory.create(tableView.dataSource.getStringValue(this, rowIndex));
    line.x = x + textInsets.left;
    line.y = y + tableView.rowHeight - textInsets.bottom;
    return line;
  }
}
}
