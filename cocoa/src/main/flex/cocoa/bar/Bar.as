package cocoa.bar
{
import cocoa.AbstractView;

import mx.core.IVisualElement;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

import org.flyti.util.List;
import org.flyti.view;
import cocoa.SelectableDataGroup;
import org.flyti.view.pane.LabeledItem;
import org.flyti.view.pane.PaneItem;
import org.flyti.view.pane.TitledPane;

import spark.components.IItemRenderer;

use namespace view;

[Abstract]
public class Bar extends AbstractView
{
	view var itemGroup:SelectableDataGroup;

	public function Bar()
	{
		super();

		skinParts.itemGroup = 0;

		listenResourceChange();
	}

	protected function get editAware():Boolean
	{
		return false;
	}

	private var itemsChanged:Boolean;
	private var _items:List/*<PaneMetadata>*/;
	public function get items():List
	{
		return _items;
	}
	public function set items(value:List):void
	{
		if (value == items)
		{
			return;
		}

		if (editAware && _items != null)
		{
			_items.removeEventListener(CollectionEvent.COLLECTION_CHANGE, itemsChangeHandler);
		}

		_items = value;

		if (editAware && _items != null)
		{
			_items.addEventListener(CollectionEvent.COLLECTION_CHANGE, itemsChangeHandler);
		}

		itemsChanged = true;
		invalidateProperties();
	}

	view function itemGroupAdded():void
	{
		itemGroup.dataProvider = items;
	}

	override public function commitProperties():void
	{
		if (itemsChanged)
		{
			itemsChanged = false;
			validateItems();
		}

		super.commitProperties();
	}

	protected function validateItems():void
	{
		itemsChanged = false;

		for each (var item:LabeledItem in items.iterator)
		{
			item.localizedLabel = itemToLabel(item);
		}

		if (itemGroup != null)
		{
			itemGroup.dataProvider = items;
		}
	}

	override protected function resourcesChanged():void
	{
		if (items == null || itemGroup == null)
		{
			return;
		}

		var i:int;
		var n:int = items.size;
		for (i = 0; i < n; i++)
		{
			var item:LabeledItem = LabeledItem(items.getItemAt(i));
			var localizedLabel:String = itemToLabel(item);
			item.localizedLabel = localizedLabel;
			if (item is PaneItem)
			{
				var paneItem:PaneItem = PaneItem(item);
				if (paneItem.view != null && paneItem.view is TitledPane)
				{
					TitledPane(paneItem.view).title = localizedLabel;
				}
			}

			var labelRenderer:IVisualElement = itemGroup.getElementAt(i);
			if (labelRenderer is IItemRenderer)
			{
				 IItemRenderer(labelRenderer).label = localizedLabel;
			}
		}
	}

	protected function itemToLabel(paneMetadata:LabeledItem):String
	{
		return resourceManager.getString(paneMetadata.label.bundleName, paneMetadata.label.resourceName);
	}

	private function itemsChangeHandler(event:CollectionEvent):void
	{
		if (event.kind == CollectionEventKind.ADD)
		{

		}
	}

//	protected function addPane(paneMetadata:PaneItem, show:Boolean):void
//	{
//
//	}
}
}