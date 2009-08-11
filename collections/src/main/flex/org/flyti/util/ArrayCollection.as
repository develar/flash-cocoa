package org.flyti.util
{
import mx.collections.ArrayCollection;

public class ArrayCollection extends mx.collections.ArrayCollection implements IListView
{
	public function ArrayCollection(source:Array = null)
	{
		super(source);
	}

	public function get empty():Boolean
	{
		return length == 0;
	}

	public function removeItem(item:Object):Object
	{
		return removeItemAt(getItemIndex(item));
	}

	public function clone():org.flyti.util.ArrayCollection
	{
		return new org.flyti.util.ArrayCollection(toArray());
	}

	public function get size():int
	{
		return length;
	}
}
}