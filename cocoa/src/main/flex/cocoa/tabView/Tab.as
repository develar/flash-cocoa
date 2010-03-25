package cocoa.tabView
{
import cocoa.Container;

import spark.layouts.HorizontalLayout;

[Abstract]
public class Tab extends Container
{
	protected var active:Boolean;

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

	override public function set visible(value:Boolean):void
	{
		if (value != visible)
		{
			super.visible = value;
			active = value;
			invalidateActiveState();
		}
	}
}
}