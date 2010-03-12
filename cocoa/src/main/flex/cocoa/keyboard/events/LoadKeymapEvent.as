package cocoa.keyboard.events
{
import cocoa.keyboard.KeymapItem;

import flash.events.Event;

public class LoadKeymapEvent extends Event
{
	public static const LOAD_KEYMAP:String = "loadKeymap";

	public function LoadKeymapEvent(keymap:Vector.<KeymapItem>, activeProfiles:Vector.<uint>)
	{
		_keymap = keymap;
		_activeProfiles = activeProfiles;
		
		super(LOAD_KEYMAP);
	}

	private var _keymap:Vector.<KeymapItem>;
	public function get keymap():Vector.<KeymapItem>
	{
		return _keymap;
	}

	private var _activeProfiles:Vector.<uint>;
	public function get activeProfiles():Vector.<uint>
	{
		return _activeProfiles;
	}
}
}