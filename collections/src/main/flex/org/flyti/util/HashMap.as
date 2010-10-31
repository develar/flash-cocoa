package org.flyti.util {
import flash.utils.Dictionary;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

[RemoteClass]
[DefaultProperty("entrySet")]
public class HashMap implements Map, IExternalizable {
  protected var storage:Object;

  public function HashMap(weakKeys:Boolean = false, data:Object = null, size:int = 0) {
    if (data == null) {
      storage = new Dictionary(weakKeys);
    }
    else {
      storage = data;
      if (size == 0) {
        for (var key:String in data) {
          _size++;
        }
      }
      else {
        _size = size;
      }
    }
  }

  public function get iterator():Object {
    return storage;
  }

  public function get empty():Boolean {
    return _size == 0;
  }

  protected var _size:int = 0;
  public function get size():int {
    return _size;
  }

  public function containsKey(key:Object):Boolean {
    return key in storage;
  }

  public function get(key:Object):Object {
    if (key == null) {
      throw new ArgumentError("key must be not null");
    }

    return storage[key];
  }

  public function put(key:Object, value:Object):void {
    if (key == null) {
      throw new ArgumentError("key must be not null");
    }

    if (!containsKey(key)) {
      _size++;
    }
    storage[key] = value;
  }

  public function remove(key:Object):Object {
    if (key == null) {
      throw new ArgumentError("key must be not null");
    }

    var value:* = storage[key];
    if (value !== undefined) {
      delete storage[key];
      _size--;
    }

    return value;
  }

  /**
   * У нас сейчас всего одна реализация интерфейса Map, поэтому putAll оптимизирован для PrimitiveHashMap
   */
  public function putAll(map:Map):void {
    for (var key:Object in HashMap(map).storage) {
      put(key, map.get(key));
    }
  }

  public function removeAll(map:Map):void {
    for (var key:Object in HashMap(map).storage) {
      delete storage[key];
    }
    _size -= map.size;
  }

  public function get keySet():Vector.<Object> {
    var i:int = size;
    var result:Vector.<Object> = new Vector.<Object>(i, true);
    for (var key:Object in storage) {
      result[--i] = key;
    }

    return result;
  }

  public function clear():void {
    _size = 0;
    for (var key:Object in storage) {
      delete storage[key];
    }
  }

  /**
   * need for DefaultProperty and must use only for it — MXML compiler
   */
  public function set entrySet(value:Vector.<MapEntry>):void {
    for each (var entry:MapEntry in value) {
      storage[entry.key] = entry.value;
    }

    _size = value.length;
  }

  public function readExternal(input:IDataInput):void {
    storage = input.readObject();
  }

  public function writeExternal(output:IDataOutput):void {
    output.writeObject(storage);
  }
}
}