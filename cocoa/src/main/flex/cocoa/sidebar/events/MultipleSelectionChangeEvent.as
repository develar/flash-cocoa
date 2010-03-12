package org.flyti.view.sidebar.events
{
import flash.events.Event;

public class MultipleSelectionChangeEvent extends Event
{
	public static const CHANGED:String = "multipleSelectionChange";

	public function MultipleSelectionChangeEvent(added:Vector.<int>, removed:Vector.<int>)
	{
		if (added != null && added.length > 0)
		{
			_added = added;
			_added.fixed = true;
		}
		if (removed != null && removed.length > 0)
		{
			_removed = removed;
			_removed.fixed = true;
		}

		super(CHANGED);
	}

	private var _added:Vector.<int>;
	/**
	 * Items indices were added to the selection interval
	 */
	public function get added():Vector.<int>
	{
		return _added;
	}

	private var _removed:Vector.<int>;
	/**
	 * Items indices were removed from the selection interval
	 */
	public function get removed():Vector.<int>
	{
		return _removed;
	}
}
}