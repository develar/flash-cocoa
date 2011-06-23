package cocoa.tableView {
import cocoa.CollectionViewDataSource;
import cocoa.Insets;
import cocoa.text.TextFormat;
import cocoa.text.TextLineRendererFactory;

import flash.display.DisplayObjectContainer;
import flash.text.engine.TextLine;

public class TextRendererManager implements RendererManager {
  protected var textLineRendererFactory:TextLineRendererFactory;
  protected const cells:TextLineLinkedList = new TextLineLinkedList();

  protected var previousEntry:TextLineLinkedListEntry;

  protected var textInsets:Insets;
  protected var textFormat:TextFormat;

  private var _lastCreatedRendererWidth:Number;

  public function TextRendererManager(textFormat:TextFormat, textInsets:Insets) {
    textLineRendererFactory = TextLineRendererFactory.instance;
    this.textInsets = textInsets;
    this.textFormat = textFormat;
  }

  protected var _dataSource:CollectionViewDataSource;
  public function set dataSource(value:CollectionViewDataSource):void {
    _dataSource = value;
  }

  protected var _container:DisplayObjectContainer;
  public function set container(value:DisplayObjectContainer):void {
    _container = value;
  }

  protected function createTextLine(itemIndex:int, w:Number):TextLine {
    return textLineRendererFactory.create(_container, _dataSource.getStringValue(itemIndex), w, textFormat.format, textFormat.swfContext);
  }

  protected function createEntry(rowIndex:int, x:Number, y:Number, w:Number, h:Number):TextLineLinkedListEntry {
    var line:TextLine = createTextLine(rowIndex, w);
    _lastCreatedRendererWidth = line.textWidth;
    line.x = x + textInsets.left;
    line.y = y + h - textInsets.bottom;
    var entry:TextLineLinkedListEntry = TextLineLinkedListEntry.create(line);
    entry.rowIndex = rowIndex;
    return entry;
  }

  public function createAndLayoutRenderer(itemIndex:int, x:Number, y:Number, w:Number, h:Number):void {
    var newEntry:TextLineLinkedListEntry = createEntry(itemIndex, x, y, w, h);
    if (previousEntry == null) {
      cells.addFirst(newEntry);
    }
    else {
      cells.addAfter(previousEntry, newEntry);
    }

    previousEntry = newEntry;
  }

  public function reuse(itemCountDelta:int, finalPass:Boolean):void {
    textLineRendererFactory.reuse(_container, cells, itemCountDelta, finalPass);
  }

  public function preLayout(head:Boolean):void {
    if (!head) {
      previousEntry = cells.tail;
    }
  }

  public function postLayout(finalPass:Boolean):void {
    if (finalPass) {
      textLineRendererFactory.postLayout(_container);
    }

    previousEntry = null;
  }

  public function get lastCreatedRendererWidth():Number {
    return _lastCreatedRendererWidth;
  }
}
}