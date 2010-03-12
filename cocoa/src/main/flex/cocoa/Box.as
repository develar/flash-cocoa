package cocoa
{
import flash.events.Event;

import org.flyti.view;
import cocoa.Container;

import spark.layouts.supportClasses.LayoutBase;

use namespace view;

[DefaultProperty("elements")]
public class Box extends AbstractView
{
	view var contentGroup:Container;

	public function Box()
	{
		super();

		skinParts.contentGroup = 0;

		listenResourceChange();
	}

	private var _elements:Array;
	public function get elements():Array
	{
		return _elements;
	}
	public function set elements(value:Array):void
	{
		_elements = value;
	}

	private var _layout:LayoutBase;
	public function set layout(value:LayoutBase):void
    {
		_layout = value;
	}

	view function contentGroupAdded():void
	{
		if (_layout != null)
		{
			contentGroup.layout = _layout;
		}

		contentGroup.elements = _elements;
	}

	protected var _resourceBundle:String;
	public function set resourceBundle(value:String):void
	{
		_resourceBundle = value;
	}

	[Bindable(event="mChanged")]
	public function m(key:String):String
	{
		return _resourceBundle == null ? null : resourceManager.getString(_resourceBundle, key);
	}

	override protected function resourcesChanged():void
    {
    	dispatchEvent(new Event("mChanged"));
    }
}
}