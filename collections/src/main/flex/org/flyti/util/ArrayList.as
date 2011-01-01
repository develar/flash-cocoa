package org.flyti.util {
import mx.collections.IList;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;
import mx.utils.OnDemandEventDispatcher;

public class ArrayList extends OnDemandEventDispatcher implements List {
  private var source:Vector.<Object>;

  public function ArrayList(source:Vector.<Object> = null) {
    this.source = source == null ? new Vector.<Object>() : source;
  }

  public function get iterator():Vector.<Object> {
    return source;
  }

  public function get length():int {
    return source.length;
  }

  public function getItemAt(index:int, prefetch:int = 0):Object {
    return source[index];
  }

  public function setItemAt(item:Object, index:int):Object {
    var oldItem:Object = source[index];
    source[index] = item;

    if (hasEventListener(CollectionEvent.COLLECTION_CHANGE)) {
      var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
      event.kind = CollectionEventKind.REPLACE;
      event.location = index;
      event.items.push(PropertyChangeEvent.createUpdateEvent(null, index, oldItem, item));
      dispatchEvent(event);
    }

    return oldItem;
  }

  public function addItem(item:Object):void {
    addItemAt(item, length);
  }

  public function addItemAt(item:Object, index:int):void {
    source.splice(index, 0, item);
    dispatchChangeEvent(CollectionEventKind.ADD, item, index);
  }

  public function getItemIndex(item:Object):int {
    return source.indexOf(item);
  }

  public function removeItemAt(index:int):Object {
    var removedItem:Object = source.splice(index, 1)[0];
    dispatchChangeEvent(CollectionEventKind.REMOVE, removedItem, index);
    return removedItem;
  }

  public function removeAll():void {
    if (source.length > 0) {
      source.length = 0;
      dispatchChangeEvent(CollectionEventKind.RESET);
    }
  }

  public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void {
    throw new Error("itemUpdated is not supported — item must be is IEventDispatcher");
  }

  public function toArray():Array {
    throw new Error("not supported");
  }

  private function dispatchChangeEvent(kind:String, item:Object = null, location:int = -1):void {
    if (hasEventListener(CollectionEvent.COLLECTION_CHANGE)) {
      dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, kind, location, -1, [item]));
    }
  }

  public function get size():int {
    return source.length;
  }

  public function get empty():Boolean {
    return source.length == 0;
  }

  public function removeItem(item:Object):Object {
    return removeItemAt(source.indexOf(item));
  }

  public function contains(item:Object):Boolean {
    return source.indexOf(item) != -1;
  }

  public function addVector(vector:Object):void {
    var start:int = source.length;
    var i:int = start;
    var n:int = vector.length;

    const restoreFixed:Boolean = source.fixed;
    if (restoreFixed) {
      source.fixed = false;
    }
    source.length = start + n;
    if (restoreFixed) {
      source.fixed = true;
    }

    for each (var item:Object in vector) {
      source[i++] = item;
    }
    dispatchChangeEventForVector(vector, start);
  }

  public function addAll(collection:IList):void {
    addVector(List(collection).iterator);
  }

  private function dispatchChangeEventForVector(vector:Object, start:int):void {
    if (hasEventListener(CollectionEvent.COLLECTION_CHANGE)) {
      for each (var item:Object in vector) {
        dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.ADD, start++, -1, [item]));
      }
    }
  }
}
}