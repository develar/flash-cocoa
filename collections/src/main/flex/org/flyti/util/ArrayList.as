package org.flyti.util
{
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.PropertyChangeEvent;
import mx.utils.OnDemandEventDispatcher;

public class ArrayList extends OnDemandEventDispatcher implements List
{
	private var source:Vector.<Object>;

	public function ArrayList(source:Vector.<Object> = null)
	{
		if (source == null)
		{
			this.source = new Vector.<Object>();
		}
		else
		{
			this.source = source;
		}
	}

	public function get length():int
    {
		return source.length;
	}

	public function getItemAt(index:int, prefetch:int = 0):Object
    {
		return source[index];
	}

	public function setItemAt(item:Object, index:int):Object
    {
		var oldItem:Object = source[index];
		source[index] = item;

		if (hasEventListener(CollectionEvent.COLLECTION_CHANGE))
		{
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE);
			event.kind = CollectionEventKind.REPLACE;
			event.location = index;
			event.items.push(PropertyChangeEvent.createUpdateEvent(null, index, oldItem, item));
			dispatchEvent(event);
		}

		return oldItem;
	}

	public function addItem(item:Object):void
    {
        addItemAt(item, length);
    }

	public function addItemAt(item:Object, index:int):void
    {
		source.splice(index, 0, item);
		dispatchChangeEvent(CollectionEventKind.ADD, item, index);
	}

	public function getItemIndex(item:Object):int
    {
		return source.indexOf(item);
	}

	public function removeItemAt(index:int):Object
	{
		var removedItem:Object = source.splice(index, 1)[0];
		dispatchChangeEvent(CollectionEventKind.REMOVE, removedItem, index);
		return removedItem;
	}

	public function removeAll():void
    {
		source.length = 0;
		dispatchChangeEvent(CollectionEventKind.RESET);
	}

	public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void
	{
		throw new Error("itemUpdated is not supported — item must be is IEventDispatcher");
	}

	public function toArray():Array
    {
		throw new Error("not supported");
	}

	private function dispatchChangeEvent(kind:String, item:Object = null, location:int = -1):void
    {
		if (hasEventListener(CollectionEvent.COLLECTION_CHANGE))
		{
			dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE, false, false, kind, location, -1, [item]));
		}
	}

	public function get size():int
	{
		return length;
	}

	public function get empty():Boolean
	{
		return length == 0;
	}

	public function removeItem(item:Object):Object
	{
		return removeItemAt(getItemIndex(item));
	}

	public function contains(item:Object):Boolean
	{
		return getItemIndex(item) != -1;
	}
}
}