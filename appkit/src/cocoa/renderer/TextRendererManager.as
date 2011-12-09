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

  protected var _lastCreatedRendererDimension:Number;
  public function get lastCreatedRendererDimension():Number {
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
      textFormat = laf.getTextFormat(laf.controlSize == "small" ? TextFormatId.SMALL_SYSTEM : TextFormatId.SYSTEM);
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

  protected function createTextLine(itemIndex:int, w:Number):TextLine {
    return textLineRendererFactory.create(textLineContainer, _dataSource.getStringValue(itemIndex), w, textFormat.format, textFormat.swfContext, true, textRotation);
  }

  protected function createEntry(itemIndex:int, x:Number, y:Number, w:Number, h:Number):TextLineEntry {
    var line:TextLine = createTextLine(itemIndex, w == w ? w : 10000);
    layoutTextLine(line, x, y, h);
    computeCreatingRendererSize(w, h, line);

    var entry:TextLineEntry = TextLineEntry.create(line);
    entry.itemIndex = itemIndex;
    return entry;
  }

  protected function computeCreatingRendererSize(w:Number, h:Number, line:TextLine):void {
    if (w != w) {
      _lastCreatedRendererDimension = Math.round(line.textWidth) + textInsets.width;
    }
    else {
      _lastCreatedRendererDimension = Math.round(line.height);
      if (textRotation == TextRotation.ROTATE_90) {
        _lastCreatedRendererDimension += textInsets.width;
      }
    }
  }

  protected function layoutTextLine(line:TextLine, x:Number, y:Number, h:Number):void {
    line.x = x + textInsets.left;
    line.y = y + (h - textInsets.bottom);
  }

  public function createAndLayoutRenderer(itemIndex:int, x:Number, y:Number, w:Number, h:Number):void {
    var newEntry:TextLineEntry = createEntry(itemIndex, x, y, w, h);
    newEntry.dimension = _lastCreatedRendererDimension;
    if (previousEntry == null) {
      cells.addFirst(newEntry);
    }
    else {
      cells.addAfter(previousEntry, newEntry);
    }

    previousEntry = newEntry;
  }

  public function createAndLayoutRendererAt(itemIndex:int, x:Number, y:Number, w:Number, h:Number, startInset:Number, gap:Number):void {
    var prevEntry:TextLineEntry;
    const isChangeWidth:Boolean = w != w;
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
    if (prevEntry == null) {
      cells.addFirst(newEntry);
    }
    else {
      cells.addAfter(prevEntry, newEntry);
    }

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
    const isChangeWidth:Boolean = w != w;
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