package cocoa.plaf.basic
{
import cocoa.HighlightableItemRenderer;
import cocoa.ItemMouseSelectionMode;
import cocoa.SelectableDataGroup;

import flash.events.MouseEvent;

public class SegmentedControlController
{
	private var itemRenderer:HighlightableItemRenderer;

	public function register(dataGroup:SelectableDataGroup):void
	{
		dataGroup.mouseSelectionMode = ItemMouseSelectionMode.NONE;
		dataGroup.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}

	private function mouseDownHandler(event:MouseEvent):void
	{
		var dataGroup:SelectableDataGroup = SelectableDataGroup(event.currentTarget);
		if (!dataGroup.hitTestPoint(event.stageX, event.stageY))
		{
			return;
		}

		itemRenderer = HighlightableItemRenderer(event.target);
		itemRenderer.highlighted = true;

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
			SelectableDataGroup(itemRenderer.owner).itemSelecting(itemRenderer.itemIndex);
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