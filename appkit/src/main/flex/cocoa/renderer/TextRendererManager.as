package cocoa.renderer {
import cocoa.Insets;
import cocoa.ListViewDataSource;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelUtil;
import cocoa.plaf.TextFormatId;
import cocoa.text.TextFormat;
import cocoa.text.TextLineRendererFactory;

import flash.display.DisplayObjectContainer;
import flash.text.engine.TextLine;
import flash.text.engine.TextRotation;

public class TextRendererManager implements RendererManager {
  protected var textLineRendererFactory:TextLineRendererFactory;
  protected const cells:TextLineLinkedList = new TextLineLinkedList();

  protected var previousEntry:TextLineEntry;

  protected var textInsets:Insets;
  protected var textFormat:TextFormat;

  private var entryFactories:Vector.<EntryFactory>;

  protected var textRotation:String;

  public function TextRendererManager(textFormat:TextFormat = null, textInsets:Insets = null) {
    textLineRendererFactory = TextLineRendererFactory.instance;
    this.textInsets = textInsets;
    this.textFormat = textFormat;
  }

  protected function get textLineContainer():DisplayObjectContainer {
    return _container;
  }

  protected var _lastCreatedRendererWidth:Number;
  public function get lastCreatedRendererWidth():Number {
    return _lastCreatedRendererWidth;
  }

  protected var _lastCreatedRendererHeigth:Number;
  public function get lastCreatedRendererHeigth():Number {
    return _lastCreatedRendererHeigth;
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
    var line:TextLine = createTextLine(itemIndex, w == w ? w : 1000000);
    layoutTextLine(line, x, y, h);
    computeCreatingRendererSize(w, h, line);

    var entry:TextLineEntry = TextLineEntry.create(line);
    entry.itemIndex = itemIndex;
    return entry;
  }

  protected function computeCreatingRendererSize(w:Number, h:Number, line:TextLine):void {
    if (w != w) {
      _lastCreatedRendererWidth = Math.round(line.textWidth) + textInsets.width;
    }
    else {
      _lastCreatedRendererHeigth = Math.round(line.height);
      if (textRotation == TextRotation.ROTATE_90) {
        _lastCreatedRendererHeigth += textInsets.width;
      }
    }
  }

  protected function layoutTextLine(line:TextLine, x:Number, y:Number, h:Number):void {
    line.x = x + textInsets.left;
    line.y = y + h - textInsets.bottom;
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

  public function postLayout(finalPass:Boolean):void {
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
}
}