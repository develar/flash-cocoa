package org.flyti.util
{
import mx.collections.IList;

public interface ICollection extends IList
{
	// https://bugs.adobe.com/jira/browse/ASC-3744
	function get size():int;
	function get empty():Boolean;
	
	function removeItem(item:Object):Object;
}
}