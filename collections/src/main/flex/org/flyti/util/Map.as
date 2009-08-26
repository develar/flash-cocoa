package org.flyti.util
{
[DefaultProperty("entrySet")]
public interface Map
{
	function get empty():Boolean;

	function get size():int;

	function containsKey(key:Object):Boolean;
	function get(key:Object):*;

	function put(key:Object, value:Object):void;
	function remove(key:Object):*;

	function putAll(map:Map):void;
	function removeAll(map:Map):void;

	function get keySet():Vector.<Object>;

	function clear():void;

	function set entrySet(value:Vector.<MapEntry>):void;
}
}