package cocoa.renderer {
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.engine.TextLine;

public class TextLineAndDisplayObjectEntryFactory implements EntryFactory {
  private const pool:Vector.<TextLineAndDisplayObjectEntry> = new Vector.<TextLineAndDisplayObjectEntry>(16, true);
  private var poolSize:int;
  private var oldPoolSize:int;

  private var displayObjectClass:Class;
  private var clearGraphics:Boolean;

  function TextLineAndDisplayObjectEntryFactory(displayObjectClass:Class, clearGraphics:Boolean = false) {
    this.displayObjectClass = displayObjectClass;
    this.clearGraphics = clearGraphics;
  }

  public function create(line:TextLine):TextLineAndDisplayObjectEntry {
    if (poolSize == 0) {
      return new TextLineAndDisplayObjectEntry(line, new displayObjectClass(), this);
    }
    else {
      var entry:TextLineAndDisplayObjectEntry = pool[--poolSize];
      entry.line = line;
      return entry;
    }
  }

  internal function addToPool(entry:TextLineAndDisplayObjectEntry):void {
    if (poolSize == pool.length) {
      pool.fixed = false;
      pool.length = poolSize << 1;
      pool.fixed = true;
    }

    if (clearGraphics) {
      if (displayObjectClass == Shape) {
        Shape(entry.displayObject).graphics.clear();
      }
      else {
        Sprite(entry.displayObject).graphics.clear();
      }
    }

    pool[poolSize++] = entry;
  }

  public function finalizeReused(container:DisplayObjectContainer):void {
    for (var i:int = oldPoolSize, n:int = poolSize; i < n; i++) {
      container.removeChild(pool[i].displayObject);
    }
    oldPoolSize = poolSize;
  }

  public function preReuse():void {
    oldPoolSize = poolSize;
  }
}
}
