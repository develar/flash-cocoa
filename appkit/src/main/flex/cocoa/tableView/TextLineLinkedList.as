package cocoa.tableView {
import flash.errors.IllegalOperationError;
import flash.text.engine.TextLine;

public class TextLineLinkedList {
  public var head:TextLineLinkedListEntry;
  public var tail:TextLineLinkedListEntry;
  public var size:int;

  private const pool:Vector.<TextLineLinkedListEntry> = new Vector.<TextLineLinkedListEntry>(128, true);
  private var poolSize:int;

  private function addToPool(o:TextLineLinkedListEntry):void {
    if (poolSize == pool.length) {
      pool.fixed = false;
      pool.length = poolSize << 1;
      pool.fixed = true;
    }
    pool[poolSize++] = o;
  }

  public function removeFirst():TextLineLinkedListEntry {
    var o:TextLineLinkedListEntry = head;
    var n:TextLineLinkedListEntry = o.next;
    o.next = null;
    if (n != null) {
      n.previous = null;
    }

    head = n;

    if (--size == 0) {
      tail = null;
    }

    addToPool(o);
    return o;
  }

  public function removeLast():TextLineLinkedListEntry {
    var o:TextLineLinkedListEntry = tail;
    var p:TextLineLinkedListEntry = o.previous;
    o.previous = null;
    if (p != null) {
      p.next = null;
    }

    tail = p;

    if (--size == 0) {
      head = null;
    }

    addToPool(o);
    return o;
  }

  public function addLast(entry:TextLineLinkedListEntry):void {
    insert(size, entry);
  }

  public function addFirst(entry:TextLineLinkedListEntry):void {
    insert(0, entry);
  }

  private function insert(index:int, entry:TextLineLinkedListEntry):void {
    if (size == 0) {
      head = tail = entry;
    }
    else if (index == 0) {
      entry.next = head;
      head.previous = entry;
      head = entry;
    }
    else if (index == size) {
      tail.next = entry;
      entry.previous = tail;
      tail = entry;
    }
    else {
      throw new IllegalOperationError();
    }

    size++;
  }

  public function addAfter(current:TextLineLinkedListEntry, entry:TextLineLinkedListEntry):void {
    if (current == tail) {
      addLast(entry);
    }
    else {
      addBefore(current.next, entry);
    }
  }

  public function addBefore(current:TextLineLinkedListEntry, entry:TextLineLinkedListEntry):void {
    if (current == head) {
      addFirst(entry);
    }
    else if (current == null) {
      addLast(entry);
    }
    else {
      var p:TextLineLinkedListEntry = current.previous;
      entry.next = current;
      p.next = entry;
      entry.previous = p;
      current.previous = entry;
      size++;
    }
  }

  public function create(line:TextLine):TextLineLinkedListEntry {
    if (poolSize == 0) {
      return new TextLineLinkedListEntry(line);
    }
    else {
      var entry:TextLineLinkedListEntry = pool[--poolSize];
      entry.line = line;
      return entry;
    }
  }
}
}
