package cocoa.tableView {
import flash.text.engine.TextLine;

public class TextLineLinkedListEntry {
  public var next:TextLineLinkedListEntry;
  public var previous:TextLineLinkedListEntry;

  public var line:TextLine;

  public function TextLineLinkedListEntry(line:TextLine):void {
    this.line = line;
  }
}
}
