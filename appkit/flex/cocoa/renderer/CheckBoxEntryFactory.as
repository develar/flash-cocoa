package cocoa.renderer {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

public class CheckBoxEntryFactory implements EntryFactory {
  private const pool:Vector.<CheckBoxEntry> = new Vector.<CheckBoxEntry>(16, true);
  private var poolSize:int;
  private var oldPoolSize:int;

  public function create(selected:Boolean):CheckBoxEntry {
    if (poolSize == 0) {
      return new CheckBoxEntry(selected, this);
    }
    else {
      var entry:CheckBoxEntry = pool[--poolSize];
      entry.checkbox.selected = selected;
      return entry;
    }
  }

  internal function addToPool(entry:CheckBoxEntry):void {
    if (poolSize == pool.length) {
      pool.fixed = false;
      pool.length = poolSize << 1;
      pool.fixed = true;
    }

    pool[poolSize++] = entry;
  }

  public function finalizeReused(container:DisplayObjectContainer):void {
    for (var i:int = oldPoolSize, n:int = poolSize; i < n; i++) {
      container.removeChild(DisplayObject(pool[i].checkbox.skin));
    }
    oldPoolSize = poolSize;
  }

  public function preReuse():void {
    oldPoolSize = poolSize;
  }
}
}
