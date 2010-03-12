package cocoa.keyboard.events
{
import cocoa.keyboard.EventMetadata;
import cocoa.keyboard.KeyboardManagerClient;

import flash.events.Event;

public class BindShortcutEvent extends Event
{
	public static const BIND_SHORTCUT:String = "bindShortcut";

	public function BindShortcutEvent(client:KeyboardManagerClient, event:EventMetadata, states:Vector.<String> = null)
	{
		_client = client;
		_event = event;
		_states = states;
		
		super(BIND_SHORTCUT, true);
	}

	private var _client:KeyboardManagerClient;
	public function get client():KeyboardManagerClient
	{
		return _client;
	}

	private var _event:EventMetadata;
	public function get event():EventMetadata
	{
		return _event;
	}

	private var _states:Vector.<String>;
	public function get states():Vector.<String>
	{
		return _states;
	}
}
}