package cocoa.sidebar
{
import org.flyti.util.Assert;
import org.flyti.view;
import cocoa.Panel;
import org.flyti.view.pane.PaneItem;
import cocoa.sidebar.events.MultipleSelectionChangeEvent;
import cocoa.sidebar.events.SidebarEvent;

import spark.components.Group;

use namespace ui;

public class Sidebar extends Bar
{
	ui var paneGroup:Group;

	private var collapsed:Boolean = true;

	private var typedPaneLabelBar:SidebarPaneLabelBar;

	public function Sidebar()
	{
		super();

		skinParts.paneGroup = 0;
	}

	override protected function get editAware():Boolean
	{
		return true;
	}

	private var pendingSelectedIndices:Vector.<int>;
	public function set selectedIndices(value:Vector.<int>):void
	{
		if (itemGroup == null)
		{
			pendingSelectedIndices = value;
		}
		else
		{
			typedPaneLabelBar.selectedIndices = value;
		}
	}

	override ui function itemGroupAdded():void
	{
		super.itemGroupAdded();

		typedPaneLabelBar = SidebarPaneLabelBar(itemGroup);
		typedPaneLabelBar.selectedIndices = pendingSelectedIndices;
		pendingSelectedIndices = null;

		itemGroup.addEventListener(MultipleSelectionChangeEvent.CHANGED, paneLabelBarSelectionChangeHandler);
	}

	ui function paneGroupAdded():void
	{
		paneGroup.includeInLayout = !collapsed;
	}

//	override protected function validateItems():void
//	{
//		super.validateItems();
//
//		for each (var item:LabeledItem in items.iterator)
//		{
//			var paneVisualElement:IVisualElement = PaneItem(items.getItemAt(i)).view;
//			if (paneVisualElement != null)
//			{
//				paneGroup.addElement(paneVisualElement);
//			}
//		}
//	}

	private function paneLabelBarSelectionChangeHandler(event:MultipleSelectionChangeEvent):void
	{
        if (event.removed != null)
        {
			showPanes(event.removed, false);
        }
		if (event.added != null)
        {
			showPanes(event.added, true);
        }

		if (collapsed != isEmpty(typedPaneLabelBar.selectedIndices))
		{
			collapsed = !collapsed;

			invalidateSkinState();
			skin.invalidateSize();

			paneGroup.includeInLayout = !collapsed;
		}
	}

	private function isEmpty(v:Vector.<int>):Boolean
    {
        return v == null || v.length == 0;
    }

	private function showPanes(indices:Vector.<int>, show:Boolean):void
	{
		for each (var index:int in indices)
		{
			showPane(PaneItem(items.getItemAt(index)), show);
		}
	}

	private function showPane(paneMetadata:PaneItem, show:Boolean):void
	{
		if (paneMetadata.view == null)
		{
			createPaneView(paneMetadata);
		}
		Panel(paneMetadata.view).hidden = !show;
	}

	private function createPaneView(paneMetadata:PaneItem):void
	{
		Assert.assert(paneMetadata.view == null);

		var pane:Panel = paneMetadata.viewFactory.newInstance();
		paneMetadata.view = pane;

		pane.title = paneMetadata.localizedLabel;

		pane.addEventListener(SidebarEvent.HIDE_PANE, hidePaneHandler);
		pane.addEventListener(SidebarEvent.HIDE_SIDE, hideSideHandler);

		if (paneGroup != null)
		{
			paneGroup.addElement(pane);
		}
	}

//	public function addPane(paneMetadata:PaneItem, show:Boolean):void
//	{
//		if (show)
//		{
//			typedPaneLabelBar.adjustSelectionIndices(items.size - 1, true);
//		}
//	}

	private function hidePaneHandler(event:SidebarEvent):void
	{
		var pane:Panel = Panel(event.currentTarget);
		Assert.assert(!pane.hidden);
		typedPaneLabelBar.adjustSelectionIndices(paneGroup.getElementIndex(pane), false);
	}

	private function hideSideHandler(event:SidebarEvent):void
	{
		selectedIndices = null;
	}
}
}