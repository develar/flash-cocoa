package cocoa.tabView
{
import cocoa.Container;

import spark.layouts.HorizontalLayout;

[Abstract]
public class Tab extends Container
{
	protected var _active:Boolean;
	public function set active(value:Boolean):void
	{
		_active = value;
		invalidateActiveState();
	}

	protected function invalidateActiveState():void
	{
		if (_active)
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

	override public function set visible(value:Boolean):void
	{
		if (value != visible)
		{
			super.visible = value;
			_active = value;
			invalidateActiveState();
		}
		else if (value && !_active)
		{
			_active = true;
			invalidateActiveState();
		}
	}
}
}