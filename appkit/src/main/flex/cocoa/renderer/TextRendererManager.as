package cocoa.renderer {
import cocoa.Insets;
import cocoa.ListViewDataSource;
import cocoa.text.TextFormat;
import cocoa.text.TextLineRendererFactory;

import flash.display.DisplayObjectContainer;
import flash.text.engine.TextLine;

public class TextRendererManager implements RendererManager {
  protected var textLineRendererFactory:TextLineRendererFactory;
  protected const cells:TextLineLinkedList = new TextLineLinkedList();

  protected var previousEntry:TextLineEntry;

  protected var textInsets:Insets;
  protected var textFormat:TextFormat;

  private var entryFactories:Vector.<EntryFactory>;

  public function TextRendererManager(textFormat:TextFormat, textInsets:Insets) {
    textLineRendererFactory = TextLineRendererFactory.instance;
    this.textInsets = textInsets;
    this.textFormat = textFormat;
  }

  protected var _lastCreatedRendererWidth:Number;
  public function get lastCreatedRendererWidth():Number {
    return _lastCreatedRendererWidth;
  }

  protected var _dataSource:ListViewDataSource;
  public function set dataSource(value:ListViewDataSource):void {
    _dataSource = value;
  }

  protected var _container:DisplayObjectContainer;
  public function set container(value:DisplayObjectContainer):void {
    _container = value;
  }

  protected function registerEntryFactory(entryFactory:EntryFactory):void {
    if (entryFactories == null) {
      entryFactories = new Vector.<EntryFactory>(1);
    }

    entryFactories[entryFactories.length] = entryFactory;
  }

  protected function createTextLine(textLineContainer:DisplayObjectContainer, itemIndex:int, w:Number):TextLine {
    return textLineRendererFactory.create(textLineContainer, _dataSource.getStringValue(itemIndex), w, textFormat.format, textFormat.swfContext);
  }

  protected function createEntry(itemIndex:int, x:Number, y:Number, w:Number, h:Number):TextLineEntry {
    var line:TextLine = createTextLine(_container, itemIndex, w);
    _lastCreatedRendererWidth = Math.ceil(line.textWidth);
    line.x = x + textInsets.left;
    line.y = y + h - textInsets.bottom;
    var entry:TextLineEntry = TextLineEntry.create(line);
    entry.itemIndex = itemIndex;
    return entry;
  }

  public function createAndLayoutRenderer(itemIndex:int, x:Number, y:Number, w:Number, h:Number):void {
    var newEntry:TextLineEntry = createEntry(itemIndex, x, y, w, h);
    if (previousEntry == null) {
      cells.addFirst(newEntry);
    }
    else {
      cells.addAfter(previousEntry, newEntry);
    }

    previousEntry = newEntry;
  }

  public function reuse(itemCountDelta:int, finalPass:Boolean):void {
    if (entryFactories != null) {
      for each (var entryFactory:EntryFactory in entryFactories) {
        entryFactory.preReuse();
      }
    }

    textLineRendererFactory.reuse(_container, cells, itemCountDelta, finalPass);

    if (finalPass && entryFactories != null) {
      clearOurPools();
    }
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

    if (entryFactories != null) {
      clearOurPools();
    }
  }

  private function clearOurPools():void {
    for each (var entryFactory:EntryFactory in entryFactories) {
      entryFactory.finalizeReused(_container);
    }
  }
}
}