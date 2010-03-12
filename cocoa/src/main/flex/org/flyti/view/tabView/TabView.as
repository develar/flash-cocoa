package org.flyti.view.tabView
{
import mx.core.IVisualElement;
import mx.core.UIComponent;

import org.flyti.util.Assert;
import org.flyti.view;
import org.flyti.view.SingleSelectionBar;
import org.flyti.view.ViewStack;
import org.flyti.view.pane.PaneItem;
import org.flyti.view.pane.TitledPane;

import spark.components.supportClasses.ListBase;
import spark.events.IndexChangeEvent;

use namespace view;

public class TabView extends SingleSelectionBar
{
	view var paneGroup:ViewStack;

	public function TabView()
	{
		super();

		skinParts.paneGroup = 0;
	}

	override protected function get editAware():Boolean
	{
		return true;
	}

	view function paneGroupAdded():void
	{
//		for (var i:int = 0, n:int = items.size; i < n; i++)
//		{
//			var paneVisualElement:IVisualElement = PaneItem(items.getItemAt(i)).view;
//			if (paneVisualElement != null)
//			{
//				paneGroup.addElement(paneVisualElement);
//			}
//		}
	}

	override protected function itemGroupSelectionChangeHandler(event:IndexChangeEvent):void
	{
		var oldItem:PaneItem;
		//  при удалении элемента, придет событие с его старым индексом, если он был ранее выделен
		if (event.oldIndex != ListBase.NO_SELECTION && event.oldIndex < items.size)
		{
        	oldItem = PaneItem(items.getItemAt(event.oldIndex));
		}
		var newItem:PaneItem = PaneItem(items.getItemAt(event.newIndex));

		if (oldItem != null /* такое только в самом начале — нам не нужно при этом кидать событие */ && hasEventListener(CurrentPaneChangeEvent.CHANGING))
		{
			dispatchEvent(new CurrentPaneChangeEvent(CurrentPaneChangeEvent.CHANGING, oldItem, newItem));
		}

		if (oldItem != null)
		{
			showPane(oldItem, false);
		}
		showPane(newItem, true);

		if (oldItem != null && hasEventListener(CurrentPaneChangeEvent.CHANGED))
		{
			dispatchEvent(new CurrentPaneChangeEvent(CurrentPaneChangeEvent.CHANGED, oldItem, newItem));
		}
	}

	protected function showPane(paneMetadata:PaneItem, show:Boolean):void
	{
		if (paneMetadata.view == null)
		{
			createPaneView(paneMetadata);
		}
		var pane:IVisualElement = paneMetadata.view;
		show ? paneGroup.show(UIComponent(pane)) : paneGroup.hide();
		if (pane is Tab)
		{
			Tab(pane).active = show;
		}
	}

	private function createPaneView(paneMetadata:PaneItem):void
	{
		Assert.assert(paneMetadata.view == null);

		var pane:IVisualElement = paneMetadata.viewFactory.newInstance();
		paneMetadata.view = pane;

		if (pane is TitledPane)
		{
			TitledPane(pane).title = paneMetadata.localizedLabel;
		}
	}
}
}