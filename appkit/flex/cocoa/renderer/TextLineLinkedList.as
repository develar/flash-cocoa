package cocoa.renderer {
import cocoa.renderer.TextLineEntry;

import flash.errors.IllegalOperationError;

public class TextLineLinkedList {
  public var head:TextLineEntry;
  public var tail:TextLineEntry;
  public var size:int;

  public function removeFirst():TextLineEntry {
    var o:TextLineEntry = head;
    var n:TextLineEntry = o.next;
    o.next = null;
    if (n != null) {
      n.previous = null;
    }

    head = n;

    if (--size == 0) {
      tail = null;
    }

    o.addToPool();
    return o;
  }

  public function removeLast():TextLineEntry {
    var o:TextLineEntry = tail;
    var p:TextLineEntry = o.previous;
    o.previous = null;
    if (p != null) {
      p.next = null;
    }

    tail = p;

    if (--size == 0) {
      head = null;
    }

    o.addToPool();
    return o;
  }

  public function remove(o:TextLineEntry):void {
    var p:TextLineEntry = o.previous;
    var n:TextLineEntry = o.next;
    if (n == null && p == null) {
      head = tail = null;
    }
    else if (n == null) {
      o.previous = null;
      p.next = null;
      tail = p;
    }
    else if (p == null) {
      o.next = null;
      n.previous = null;
      head = n;
    }
    else {
      p.next = n;
      n.previous = p;
      o.previous = null;
      o.next = null;
    }

    size--;
    o.addToPool();
  }

  public function addLast(entry:TextLineEntry):void {
    insert(size, entry);
  }

  public function addFirst(entry:TextLineEntry):void {
    insert(0, entry);
  }

  private function insert(index:int, entry:TextLineEntry):void {
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

  public function addAfter(current:TextLineEntry, entry:TextLineEntry):void {
    if (current == tail) {
      addLast(entry);
    }
    else {
      addBefore(current.next, entry);
    }
  }

  public function addBefore(current:TextLineEntry, entry:TextLineEntry):void {
    if (current == head) {
      addFirst(entry);
    }
    else if (current == null) {
      addLast(entry);
    }
    else {
      var p:TextLineEntry = current.previous;
      entry.next = current;
      p.next = entry;
      entry.previous = p;
      current.previous = entry;
      size++;
    }
  }
}
}