package cocoa.tabView
{
import cocoa.ListSelection;
import cocoa.SingleSelectionBar;
import cocoa.ViewStack;
import cocoa.Viewable;
import cocoa.bar.Bar;
import cocoa.pane.PaneItem;
import cocoa.pane.TitledPane;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.Skin;
import cocoa.ui;

import flash.utils.Dictionary;

import spark.events.IndexChangeEvent;

use namespace ui;

public class TabView extends SingleSelectionBar
{
	public static const DEFAULT:int = 0;
	public static const BORDERLESS:int = 1;

	protected static const _skinParts:Dictionary = new Dictionary();
	_cl(_skinParts, Bar._skinParts);
	_skinParts.viewStack = HANDLER_NOT_EXISTS;
	override protected function get skinParts():Dictionary
	{
		return _skinParts;
	}

	ui var viewStack:ViewStack;

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

		showPane(newItem);

		if (oldItem != null && hasEventListener(CurrentPaneChangeEvent.CHANGED))
		{
			dispatchEvent(new CurrentPaneChangeEvent(CurrentPaneChangeEvent.CHANGED, oldItem, newItem));
		}
	}

	protected function showPane(paneItem:PaneItem):void
	{
		if (paneItem.view == null)
		{
			createPaneView(paneItem);
		}
		var pane:Viewable = paneItem.view;
		viewStack.show(pane);
	}

	protected function createPaneView(paneItem:PaneItem):void
	{
		assert(paneItem.view == null);

		var pane:Viewable = paneItem.viewFactory.newInstance();
		paneItem.view = pane;

		if (pane is TitledPane)
		{
			TitledPane(pane).title = paneItem.localizedLabel;
		}
	}

	override protected function get defaultLaFPrefix():String
	{
		return "TabView";
	}

	private var _style:int = DEFAULT;
	public function set style(value:int):void
	{
		_style = value;
	}

	override public function createView(laf:LookAndFeel):Skin
	{
		if (_skinClass == null)
		{
			_skinClass = laf.getClass(_style == DEFAULT ? lafPrefix : (lafPrefix + ".borderless"));
		}
		return super.createView(laf);
	}
}
}