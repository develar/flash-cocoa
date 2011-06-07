package cocoa.plaf.basic {
import cocoa.Border;
import cocoa.Icon;
import cocoa.plaf.CursorData;
import cocoa.plaf.LookAndFeel;
import cocoa.text.TextFormat;

import flash.geom.Point;
import flash.utils.Dictionary;

import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.formats.ITextLayoutFormat;

import mx.core.DeferredInstanceFromClass;
import mx.core.IFactory;

[Abstract]
public class AbstractLookAndFeel implements LookAndFeel {
  protected const data:Dictionary = new Dictionary();

  public final function get defaults():Dictionary {
    return data;
  }

  protected var _parent:LookAndFeel;
  public function set parent(value:LookAndFeel):void {
    _parent = value;
  }
  
  public function get controlSize():String {
    return null;
  }

  public function getBorder(key:String, nullable:Boolean = false):Border {
    var value:* = data[key];
    if (nullable && value === null) {
      return null;
    }
    else if (value != null) {
      return Border(value is Border ? value : DeferredInstanceFromClass(value).getInstance());
    }
    else if (_parent == null) {
      if (nullable) {
        return null;
      }
      else {
        throw new ArgumentError("Unknown " + key);
      }
    }
    else {
      return _parent.getBorder(key, nullable);
    }
  }

  public function getObject(key:String):Object {
    var value:Object = data[key];
    if (value != null) {
      return value;
    }
    else if (_parent == null) {
      throw new ArgumentError("Unknown " + key);
    }
    else {
      return _parent.getObject(key);
    }
  }

  public function getPoint(key:String):Point {
    var value:Point = data[key];
    if (value != null) {
      return value;
    }
    else if (_parent == null) {
      throw new ArgumentError("Unknown " + key);
    }
    else {
      return _parent.getPoint(key);
    }
  }

  public function getInt(key:String):int {
    var value:* = data[key];
    if (value != undefined) {
      return value;
    }
    else if (_parent == null) {
      throw new ArgumentError("Unknown " + key);
    }
    else {
      return _parent.getInt(key);
    }
  }

  public function getString(key:String, nullable:Boolean = false):String {
    var value:String = data[key];
    if (value != null) {
      return value;
    }
    else if (_parent == null) {
      if (nullable) {
        return null;
      }
      else {
        throw new ArgumentError("Unknown " + key);
      }
    }
    else {
      return _parent.getString(key, false);
    }
  }

  public function getIcon(key:String):Icon {
    var value:Object = data[key];
    if (value != null) {
      return Icon(value is Icon ? value : DeferredInstanceFromClass(value).getInstance());
    }
    else if (_parent == null) {
      throw new ArgumentError("Unknown " + key);
    }
    else {
      return _parent.getIcon(key);
    }
  }

  public function getTextFormat(key:String):TextFormat {
    var value:TextFormat = data[key];
    if (value != null) {
      return value;
    }
    else if (_parent == null) {
      throw new ArgumentError("Unknown " + key);
    }
    else {
      return _parent.getTextFormat(key);
    }
  }

  public function getTextLayoutFormat(key:String):ITextLayoutFormat {
    var value:ITextLayoutFormat = data[key];
    if (value != null) {
      return value;
    }
    else if (_parent == null) {
      throw new ArgumentError("Unknown " + key);
    }
    else {
      return _parent.getTextLayoutFormat(key);
    }
  }

  public function getSelectionFormat(key:String):SelectionFormat {
    var value:SelectionFormat = data[key];
    if (value != null) {
      return value;
    }
    else if (_parent == null) {
      throw new ArgumentError("Unknown " + key);
    }
    else {
      return _parent.getSelectionFormat(key);
    }
  }

  public function getClass(key:String):Class {
    var value:Class = data[key];
    if (value != null) {
      return value;
    }
    else if (_parent == null) {
      throw new ArgumentError("Unknown " + key);
    }
    else {
      return _parent.getClass(key);
    }
  }

  public function getFactory(key:String, nullable:Boolean = false):IFactory {
    var value:IFactory = data[key];
    if (value != null) {
      return value;
    }
    else if (_parent == null) {
      if (nullable) {
        return null;
      }
      else {
        throw new ArgumentError("Unknown " + key);
      }
    }
    else {
      return _parent.getFactory(key, false);
    }
  }

  public function getCursor(cursorType:int):CursorData {
    var value:CursorData = data[cursorType];
    if (value != null) {
      return value;
    }
    else if (_parent == null) {
      throw new ArgumentError("Unknown " + cursorType);
    }
    else {
      return _parent.getCursor(cursorType);
    }
  }

  public function getColors(key:String):Vector.<uint> {
    var value:Vector.<uint> = data[key];
    if (value != null) {
      return value;
    }
    else if (_parent == null) {
      throw new ArgumentError("Unknown " + key);
    }
    else {
      return _parent.getColors(key);
    }
  }
}
}