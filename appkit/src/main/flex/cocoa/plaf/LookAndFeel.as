package cocoa.plaf {
import cocoa.Border;
import cocoa.Icon;
import cocoa.text.TextFormat;

import flash.geom.Point;
import flash.utils.Dictionary;

import flashx.textLayout.edit.SelectionFormat;
import flashx.textLayout.formats.ITextLayoutFormat;

import mx.core.IFactory;

public interface LookAndFeel {
  function get defaults():Dictionary;

  function set parent(value:LookAndFeel):void;

  function getBorder(key:String, nullable:Boolean = false):Border;

  function getIcon(key:String):Icon;

  function getTextFormat(key:String):TextFormat;

  function getTextLayoutFormat(key:String):ITextLayoutFormat;

  function getSelectionFormat(key:String):SelectionFormat;

  function getClass(key:String):Class;

  function getFactory(key:String, nullable:Boolean = false):IFactory;

  function getCursor(cursorType:int):CursorData;

  function getColors(key:String):Vector.<uint>;

  function getObject(key:String, nullable:Boolean = false):Object;

  function getPoint(key:String):Point;

  function getInt(key:String):int;
  function getString(key:String, nullable:Boolean = false):String;

  function get controlSize():String;
}
}