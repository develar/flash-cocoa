package org.flyti.view.tabView
{
import cocoa.Container;

import spark.layouts.HorizontalLayout;

[Abstract]
public class Tab extends Container
{
	private var _active:Boolean;
	public function get active():Boolean
	{
		return _active;
	}
	public function set active(value:Boolean):void
	{
		if (value != active)
		{
			_active = value;
			invalidateActiveState();
		}
	}

	protected function invalidateActiveState():void
	{
		if (active)
		{
			commitActiveState();
		}
	}

	protected function commitActiveState():void
	{
	}

	override protected function createChildren():void
	{
		if (layout == null)
		{
			layout = new HorizontalLayout();
		}

		super.createChildren();
	}
}
}