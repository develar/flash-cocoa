package cocoa.plaf
{
import cocoa.SingleSelectionDataGroup;

import flash.events.MouseEvent;

public class SegmentedControlController
{
	private var wasSelected:Boolean;

	private var itemRenderer:AbstractItemRenderer;

	public function register(dataGroup:SingleSelectionDataGroup):void
	{
		dataGroup.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}

	private function mouseDownHandler(event:MouseEvent):void
	{
		var dataGroup:SingleSelectionDataGroup = SingleSelectionDataGroup(event.currentTarget);
		if (!dataGroup.hitTestPoint(event.stageX, event.stageY))
		{
			return;
		}

		itemRenderer = AbstractItemRenderer(event.target);
		itemRenderer.highlighted = true;
		wasSelected = itemRenderer.selected;

		dataGroup.stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

		itemRenderer.addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		itemRenderer.addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);

		event.updateAfterEvent();
	}

	private function stageMouseUpHandler(event:MouseEvent):void
	{
		itemRenderer.stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);

		itemRenderer.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
		itemRenderer.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);

		if (itemRenderer == event.target)
		{
			itemRenderer.highlighted = false;
			if (!wasSelected)
			{
				itemRenderer.selected = true;
				SingleSelectionDataGroup(itemRenderer.owner).selectedIndex = itemRenderer.itemIndex;
			}
			event.updateAfterEvent();
		}

		itemRenderer = null;
	}

	private function mouseOverHandler(event:MouseEvent):void
	{
		itemRenderer.highlighted = true;
		event.updateAfterEvent();
	}

	private function mouseOutHandler(event:MouseEvent):void
	{
		itemRenderer.highlighted = false;
		event.updateAfterEvent();
	}
}
}