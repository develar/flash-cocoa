package cocoa.hudInspector
{
import cocoa.HUDWindow;
import cocoa.dialog.DialogManager;
import cocoa.pane.PaneItem;
import cocoa.plaf.Skin;
import cocoa.resources.ResourceManager;
import cocoa.tabView.Tab;

import flash.utils.Dictionary;

import org.flyti.plexus.plexus;

use namespace plexus;

public class HUDInspectorManager
{
	private var inspectorSetMap:Dictionary/*<Class, PaneItem>*/ = new Dictionary();
	private var currentInspector:HUDWindow;

	private var cache:Dictionary/*<PaneItem, HUDWindow>*/;

	public function register(objectClass:Class, inspectorItem:PaneItem):void
	{
		inspectorSetMap[objectClass] = inspectorItem;
	}

	private var dialogManager:DialogManager;
	plexus function set dialogManager(value:DialogManager):void
	{
		dialogManager = value;
	}

	public function show(element:Object):void
	{
		assert(currentInspector == null);

		var clazz:Class = Class(element.constructor);
		var inspectorItem:PaneItem = inspectorSetMap[clazz];
		if (inspectorItem == null)
		{
			return;
		}

		if (cache == null)
		{
			cache = new Dictionary();
		}
		else
		{
			currentInspector = cache[inspectorItem];
		}

		if (currentInspector == null)
		{
			currentInspector = new HUDWindow();
			currentInspector.title = ResourceManager.instance.getStringByRM(inspectorItem.label);
			inspectorItem.view = currentInspector.contentView = inspectorItem.viewFactory.newInstance();
			if (inspectorItem.view is Tab)
			{
				Tab(inspectorItem.view).active = true;
			}
			cache[inspectorItem] = currentInspector;
		}

		dialogManager.open(currentInspector, false, false);
		var view:Skin = currentInspector.skin;
		view.move(100, 200);
	}

	public function hide(element:Object, relatedElement:Object):void
	{
		if (currentInspector == null || (relatedElement != null && element.constructor == relatedElement.constructor))
		{
			return;
		}

		if (currentInspector.contentView is Tab)
		{
			Tab(currentInspector.contentView).active = false;
		}

		dialogManager.close(currentInspector);
	}
}
}