package org.flyti.util
{
import mx.collections.IList;

public interface Collection extends IList
{
	// https://bugs.adobe.com/jira/browse/ASC-3744
	function get size():int;
	function get empty():Boolean;

	function contains(item:Object):Boolean
	
	function removeItem(item:Object):Object;

	function addAll(collection:IList):void;
}
}