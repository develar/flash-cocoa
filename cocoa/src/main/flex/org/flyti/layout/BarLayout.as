package org.flyti.layout
{
import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

public class BarLayout extends LayoutBase
{
	private var _gap:int = 0;
	/**
	 *  The space between layout elements.
	 */
	public function get gap():int
	{
		return _gap;
	}
	public function set gap(value:int):void
	{
		if (value == _gap)
		{
			return;
		}

		_gap = value;

		var layoutTarget:GroupBase = target;
		if (layoutTarget != null)
		{
			layoutTarget.invalidateSize();
			layoutTarget.invalidateDisplayList();
		}
	}
}
}