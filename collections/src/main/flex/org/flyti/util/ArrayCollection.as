package org.flyti.util {
import flash.errors.IllegalOperationError;

import mx.collections.ArrayCollection;

public class ArrayCollection extends mx.collections.ArrayCollection implements CollectionView {
  public function ArrayCollection(source:Array = null) {
    super(source);
  }

  public function get empty():Boolean {
    return length == 0;
  }

  public function removeItem(item:Object):Object {
    return removeItemAt(getItemIndex(item));
  }

  public function clone():org.flyti.util.ArrayCollection {
    return new org.flyti.util.ArrayCollection(toArray());
  }

  public function get size():int {
    return length;
  }

  /**
   * Со стандартной реализацией были проблемы, оно не могло найти в localIndex элемент при удалении.
   * К тому же, нам совершенно не нужно все то, что в стандартной реализации — у нас элемент в коллекции всегда один.
   */
  override public function getItemIndex(item:Object):int {
    return (localIndex == null ? source : localIndex).indexOf(item);
  }

  public function get iterator():Vector.<Object> {
    throw new IllegalOperationError("unsupported");
  }
}
}