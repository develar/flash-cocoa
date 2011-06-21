package cocoa.tableView {
import flash.text.engine.TextLine;

public class TextLineLinkedListEntry {
  private static const pool:Vector.<TextLineLinkedListEntry> = new Vector.<TextLineLinkedListEntry>(32, true);
  private static var poolSize:int;

  public var rowIndex:int;

  public var next:TextLineLinkedListEntry;
  public var previous:TextLineLinkedListEntry;

  public var line:TextLine;

  public function TextLineLinkedListEntry(line:TextLine):void {
    this.line = line;
  }

  public static function create(line:TextLine):TextLineLinkedListEntry {
    if (poolSize == 0) {
      return new TextLineLinkedListEntry(line);
    }
    else {
      var entry:TextLineLinkedListEntry = pool[--poolSize];
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