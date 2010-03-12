package cocoa.pane
{
import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;

import org.flyti.lang.Enum;
import org.flyti.util.ArrayList;
import org.flyti.util.List;

public class PaneManager
{
	private var collectionMap:Dictionary = new Dictionary();

	/**
	 * Если при addPane нет зарегистрированной коллекции — сохраняем в pending и добавляем при регистрации
	 * id => Vector.<PaneItem>
	 */
	private var pendingItems:Dictionary;

	public function registerPaneCollection(id:Enum, list:List):void
	{
		if (id in collectionMap)
		{
			throw new IllegalOperationError("Pane Collection with id " + id + " already registered");
		}
		else
		{
			collectionMap[id] = list;
			if (pendingItems != null)
			{
				var pending:Vector.<PaneItem> = pendingItems[id];
				if (pending != null)
				{
					ArrayList(list).addVector(pending);
				}
			}
		}
	}

	public function addPane(id:Enum, paneItem:PaneItem):void
	{
		var list:List = collectionMap[id];
		if (list == null)
		{
			var pending:Vector.<PaneItem>;
			if (pendingItems == null)
			{
				pendingItems = new Dictionary();
			}
			else
			{
				pending = pendingItems[id];
			}
			
			if (pending == null)
			{
				pendingItems[id] = new <PaneItem>[paneItem];
			}
			else
			{
				pending.push(paneItem);
			}
		}
		else
		{
			list.addItem(paneItem);
		}
	}
}
}