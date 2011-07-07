package cocoa.renderer {
import flash.text.engine.TextLine;

public class TextLineEntry {
  private static const pool:Vector.<TextLineEntry> = new Vector.<TextLineEntry>(32, true);
  private static var poolSize:int;

  public var itemIndex:int;

  public var next:TextLineEntry;
  public var previous:TextLineEntry;

  public var line:TextLine;

  public function TextLineEntry(line:TextLine):void {
    this.line = line;
  }

  public static function create(line:TextLine):TextLineEntry {
    if (poolSize == 0) {
      return new TextLineEntry(line);
    }
    else {
      var entry:TextLineEntry = pool[--poolSize];
      entry.line = line;
      return entry;
    }
  }

  public function addToPool():void {
    if (poolSize == pool.length) {
      pool.fixed = false;
      pool.length = poolSize << 1;
      pool.fixed = true;
    }
    pool[poolSize++] = this;
  }
}
}