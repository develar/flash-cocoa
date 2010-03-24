package cocoa.tabView
{
import cocoa.ListSelection;
import cocoa.SingleSelectionBar;
import cocoa.ViewStack;
import cocoa.Viewable;
import cocoa.bar.Bar;
import cocoa.pane.PaneItem;
import cocoa.pane.TitledPane;
import cocoa.ui;

import flash.utils.Dictionary;

import mx.core.UIComponent;

import org.flyti.util.Assert;

import spark.events.IndexChangeEvent;

use namespace ui;

public class TabView extends SingleSelectionBar
{
	protected static const _skinParts:Dictionary = new Dictionary();
	_cl(_skinParts, Bar._skinParts);
	_skinParts.paneGroup = HANDLER_NOT_EXISTS;
	override protected function get skinParts():Dictionary
	{
		return _skinParts;
	}

	ui var paneGroup:ViewStack;

	override protected function get editAware():Boolean
	{
		return true;
	}

	override protected function itemGroupSelectionChangeHandler(event:IndexChangeEvent):void
	{
		var oldItem:PaneItem;
		//  при удалении элемента, придет событие с его старым индексом, если он был ранее выделен
		if (event.oldIndex != ListSelection.NO_SELECTION && event.oldIndex < items.size)
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
		var pane:Viewable = paneMetadata.view;
		show ? paneGroup.show(UIComponent(pane)) : paneGroup.hide();
		if (pane is Tab)
		{
			Tab(pane).active = show;
		}
	}

	private function createPaneView(paneMetadata:PaneItem):void
	{
		Assert.assert(paneMetadata.view == null);

		var pane:Viewable = paneMetadata.viewFactory.newInstance();
		paneMetadata.view = pane;

		if (pane is TitledPane)
		{
			TitledPane(pane).title = paneMetadata.localizedLabel;
		}
	}

	override public function get lafPrefix():String
	{
		return "TabView";
	}
}
}