package cocoa.renderer {
import cocoa.Insets;
import cocoa.ListViewDataSource;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.TextFormatId;
import cocoa.text.TextFormat;
import cocoa.text.TextLineRendererFactory;

import flash.display.DisplayObjectContainer;
import flash.errors.IllegalOperationError;
import flash.text.engine.TextLine;
import flash.text.engine.TextRotation;

public class TextRendererManager implements RendererManager {
  protected var textLineRendererFactory:TextLineRendererFactory;
  protected const cells:TextLineLinkedList = new TextLineLinkedList();

  protected var previousEntry:TextLineEntry;

  protected var textInsets:Insets;
  protected var textFormat:TextFormat;

  protected var entryFactories:Vector.<EntryFactory>;

  protected var textRotation:String;

  public function TextRendererManager(textFormat:TextFormat = null, textInsets:Insets = null) {
    textLineRendererFactory = TextLineRendererFactory.instance;
    this.textFormat = textFormat;
    this.textInsets = textInsets;
  }

  protected function get textLineContainer():DisplayObjectContainer {
    return _container;
  }

  protected var _lastCreatedRendererDimension:int;
  public function get lastCreatedRendererDimension():int {
    return _lastCreatedRendererDimension;
  }

  protected var _dataSource:ListViewDataSource;
  public function set dataSource(value:ListViewDataSource):void {
    _dataSource = value;
  }

  protected var _container:DisplayObjectContainer;
  public function set container(value:DisplayObjectContainer):void {
    _container = value;

    if (textFormat == null) {
      var laf:LookAndFeel = LookAndFeelUtil.find(_container);
      textFormat = laf.getTextFormat(laf.controlSize == null ? TextFormatId.SYSTEM : TextFormatId.SMALL_SYSTEM);
    }
  }

  protected function registerEntryFactory(entryFactory:EntryFactory):void {
    if (entryFactories == null) {
      entryFactories = new Vector.<EntryFactory>();
    }

    entryFactories[entryFactories.length] = entryFactory;
  }

  public function findEntry(itemIndex:int):TextLineEntry {
    var entry:TextLineEntry;
    if (itemIndex < (_dataSource.itemCount >> 1)) {
      entry = cells.head;
      if (entry == null) {
        return null;
      }

      do {
        if (entry.itemIndex == itemIndex) {
          return entry;
        }
      }
      while ((entry = entry.next) != null);
    }
    else {
      entry = cells.tail;
      if (entry == null) {
        return null;
      }
      
      do {
        if (entry.itemIndex == itemIndex) {
          return entry;
        }
      }
      while ((entry = entry.previous) != null);
    }

    return null;
  }

  protected function createTextLine(itemIndex:int, w:int):TextLine {
    return textLineRendererFactory.create(textLineContainer, _dataSource.getStringValue(itemIndex), w, textFormat.format, textFormat.swfContext, true, textRotation);
  }

  protected function createEntry(itemIndex:int, x:Number, y:Number, w:int, h:int):TextLineEntry {
    var line:TextLine = createTextLine(itemIndex, w == -1 ? 10000 : w);
    layoutTextLine(line, x, y, h);
    computeCreatingRendererSize(w, h, line);

    var entry:TextLineEntry = TextLineEntry.create(line);
    entry.itemIndex = itemIndex;
    return entry;
  }

  protected function computeCreatingRendererSize(w:int, h:int, line:TextLine):void {
    if (w == -1) {
      _lastCreatedRendererDimension = Math.round(line.textWidth) + textInsets.width;
    }
    else {
      _lastCreatedRendererDimension = Math.round(line.height);
      if (textRotation == TextRotation.ROTATE_90) {
        _lastCreatedRendererDimension += textInsets.width;
      }
    }
  }

  protected function layoutTextLine(line:TextLine, x:Number, y:Number, h:int):void {
    line.x = x + textInsets.left;
    line.y = y + (h - textInsets.bottom);
  }

  public final function createAndLayoutRenderer(itemIndex:int, x:Number, y:Number, w:int, h:int):void {
    var newEntry:TextLineEntry = createEntry(itemIndex, x, y, w, h);
    finalizeEntryAddition(newEntry, previousEntry);
    previousEntry = newEntry;
  }

  private function finalizeEntryAddition(newEntry:TextLineEntry, prevEntry:TextLineEntry):void {
    newEntry.dimension = _lastCreatedRendererDimension;
    if (prevEntry == null) {
      cells.addFirst(newEntry);
    }
    else {
      cells.addAfter(prevEntry, newEntry);
    }
  }

  public final function createAndLayoutRendererAt(itemIndex:int, x:Number, y:Number, w:int, h:int, startInset:int, gap:int):void {
    var prevEntry:TextLineEntry;
    const isChangeWidth:Boolean = w == -1;
    var e:TextLineEntry;
    if (isChangeWidth) {
      x = startInset;
      if (itemIndex != 0) {
        e = cells.head;
        do {
          x += e.dimension + gap;
          if (e.itemIndex == itemIndex) {
            break;
          }
        }
        while ((e = e.next) != null);

        prevEntry = e == null ? cells.tail : e;
      }
    }
    else{
      throw new IllegalOperationError("not implemented");
    }
    
    var newEntry:TextLineEntry = createEntry(itemIndex, x, y, w, h);
    finalizeEntryAddition(newEntry, prevEntry);

    e = newEntry;
    while ((e = e.next) != null) {
      e.itemIndex++;
      if (isChangeWidth) {
        e.moveX(_lastCreatedRendererDimension);
      }
      else {
        e.moveY(_lastCreatedRendererDimension);
      }
      
      entryMoved(e, isChangeWidth);
    }
  }

  protected function entryMoved(e:TextLineEntry, isChangeWidth:Boolean):void {
    
  }

  public function removeRenderer(itemIndex:int, x:Number, y:Number, w:Number, h:Number):void {
    var removedEntry:TextLineEntry = findEntry(itemIndex);
    var nextEntry:TextLineEntry = removedEntry.next;

    if (entryFactories != null) {
      for each (var entryFactory:EntryFactory in entryFactories) {
        entryFactory.preReuse();
      }
    }

    textLineRendererFactory.reuseRemoved(textLineContainer, cells, removedEntry);

    if (entryFactories != null) {
      clearOurPools();
    }

    _lastCreatedRendererDimension = removedEntry.dimension;
    if (nextEntry == null) {
      return;
    }

    var e:TextLineEntry = nextEntry;
    const isChangeWidth:Boolean = w == -1;
    do {
      e.itemIndex--;
      if (isChangeWidth) {
        e.moveX(-_lastCreatedRendererDimension);
      }
      else {
        e.moveY(-_lastCreatedRendererDimension);
      }
    }
    while ((e = e.next) != null);
  }

  public function reuse(itemCountDelta:int, finalPass:Boolean):void {
    if (entryFactories != null) {
      for each (var entryFactory:EntryFactory in entryFactories) {
        entryFactory.preReuse();
      }
    }

    textLineRendererFactory.reuse(textLineContainer, cells, itemCountDelta, finalPass);

    if (finalPass && entryFactories != null) {
      clearOurPools();
    }
  }

  public function preLayout(head:Boolean):void {
    if (!head) {
      previousEntry = cells.tail;
    }
  }

  public function postLayout(finalPass:Boolean = true):void {
    if (finalPass) {
      textLineRendererFactory.postLayout(textLineContainer);
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

  public function get renderedItemCount():int {
    return cells.size;
  }
}
}