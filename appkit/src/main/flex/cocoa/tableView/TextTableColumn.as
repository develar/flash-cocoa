package cocoa.tableView {
import cocoa.Insets;
import cocoa.text.TextLineRendererFactory;

import flash.display.DisplayObject;
import flash.errors.IllegalOperationError;
import flash.text.engine.TextLine;

public class TextTableColumn extends TableColumn {
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

  override public function createAndLayoutRenderer(rowIndex:int, relativeRowIndex:Number, x:Number, y:Number):DisplayObject {
    var line:TextLine = textLineRendererFactory.create(tableView.dataSource.getStringValue(this, rowIndex));
    visibleRenderers[relativeRowIndex] = line;

    //if (visibleRenderers.indexOf(line) != visibleRenderers.lastIndexOf(line)) {
    //  throw new IllegalOperationError();
    //}

    line.x = x + textInsets.left;
    line.y = y + tableView.rowHeight - textInsets.bottom;
    return line;
  }

  override public function reuse(numberOfRenderers:int):void {
    textLineRendererFactory.reuse(visibleRenderers, numberOfRenderers);
  }

  override public function moveValidVisibleRenderersByY(numberOfRenderers:int):void {
    var i:int;
    if (numberOfRenderers > 0) {
      for (i = numberOfRenderers; i < visibleRenderers.length; i++) {
        visibleRenderers[i - numberOfRenderers] = visibleRenderers[i];
      }
    }
    else {
      for (i = visibleRenderers.length + numberOfRenderers - 1; i >= 0; i--) {
        visibleRenderers[i - numberOfRenderers] = visibleRenderers[i];
      }
    }
  }

  override public function preLayout(numberOfVisibleRows:int):void {
    if (visibleRenderers.length == numberOfVisibleRows) {
      return;
    }
    
    visibleRenderers.fixed = false;
    visibleRenderers.length = numberOfVisibleRows;
    visibleRenderers.fixed = true;
  }

  override public function postLayout():void {
    textLineRendererFactory.postLayout();
  }
}
}