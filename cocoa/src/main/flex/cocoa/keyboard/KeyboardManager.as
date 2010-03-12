package cocoa.keyboard
{
import flash.display.InteractiveObject;
import flash.events.KeyboardEvent;
import flash.utils.Dictionary;

import spark.components.RichEditableText;

public class KeyboardManager
{
	private var commandShortcuts:Dictionary;
	private var commandShiftShortcuts:Dictionary;
	private var shortcuts:Dictionary;

	private var clientBinder:ClientBinder = new ClientBinder();

	private var keymapLoaded:Boolean = false;

	public function loadKeymap(keymap:Vector.<KeymapItem>, activeProfiles:Vector.<uint>):void
	{
		shortcuts = new Dictionary();
		commandShortcuts = new Dictionary();
		commandShiftShortcuts = new Dictionary();

		clientBinder.eventShortcutMap = new Dictionary();

		for each (var item:KeymapItem in keymap)
		{
			var shortcutLabelRegistered:Boolean = false;
			for each (var shortcut:Shortcut in item.shortcuts)
			{
				if (shortcut.profile == Shortcut.ANY_PROFILE || activeProfiles.indexOf(shortcut.profile) != -1)
				{
					if (!shortcutLabelRegistered)
					{
						shortcutLabelRegistered = true;
						clientBinder.eventShortcutMap[item.event.type] = shortcut;
					}

					var map:Object;
					if (shortcut.command)
					{
						if (shortcut.shift)
						{
							map = commandShiftShortcuts;
						}
						else
						{
							map = commandShortcuts;
						}
					}
					else
					{
						map = shortcuts;
					}

					if (shortcut.code in map)
					{
						Vector.<KeymapItem>(map[shortcut.code]).push(item);
					}
					else
					{
						map[shortcut.code] = new <KeymapItem>[item];
					}
				}
			}
		}

		keymapLoaded = true;
		clientBinder.updateClients();
	}

	public function keyDownHandler(event:KeyboardEvent):void
	{
		if (!keymapLoaded)
		{
			return;
		}
		
		var items:Vector.<KeymapItem>;
		if (event.ctrlKey && !event.altKey)
		{
			if (event.shiftKey)
			{
				items = commandShiftShortcuts[event.keyCode];
			}
			else
			{
				items = commandShortcuts[event.keyCode];
			}
		}
		else if (!(event.target is RichEditableText && RichEditableText(event.target).editable))
		{
            items = shortcuts[event.keyCode];
		}

		if (items != null)
		{
			for each (var item:KeymapItem in items)
			{
				dispatch(item, InteractiveObject(event.target));
			}
		}
	}

	public function bindShortcut(client:KeyboardManagerClient, eventMetadata:EventMetadata, states:Vector.<String> = null):void
	{
		clientBinder.bindShortcut(client, eventMetadata, states);
	}

	private function dispatch(item:KeymapItem, target:InteractiveObject):void
	{
		target.dispatchEvent(item.event.create());
	}
}
}