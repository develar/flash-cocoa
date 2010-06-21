package cocoa
{
import cocoa.text.EditableTextView;

import flash.utils.Dictionary;

import spark.events.TextOperationEvent;

use namespace ui;

public class TextInput extends AbstractComponent
{
	protected static const _skinParts:Dictionary = new Dictionary();
	_skinParts.textDisplay = 0;
	override protected function get skinParts():Dictionary
	{
		return _skinParts;
	}

	ui var textDisplay:EditableTextView;

	private var _text:String;
	public function get text():String
	{
		return textDisplay == null ? _text : textDisplay.text;
	}

	public function set text(value:String):void
	{
		if (value != _text)
		{
			_text = value;
			if (textDisplay != null)
			{
				textDisplay.text = _text;
			}
		}
	}

	ui function textDisplayAdded():void
	{
		textDisplay.text = _text;
		textDisplay.addEventListener(TextOperationEvent.CHANGE, inputChangeHandler);
	}

	private function inputChangeHandler(event:TextOperationEvent):void
	{
		dispatchEvent(event);
	}

	override protected function get defaultLaFPrefix():String
	{
		return "TextInput";
	}
}
}