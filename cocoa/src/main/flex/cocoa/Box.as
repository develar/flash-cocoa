package cocoa
{
import flash.events.Event;

import spark.layouts.supportClasses.LayoutBase;

use namespace ui;

[DefaultProperty("elements")]
public class Box extends AbstractComponent
{
	ui var contentGroup:Container;

	public function Box()
	{
		super();

		skinParts.contentGroup = 0;

		listenResourceChange();
	}

	private var _elements:Array;

	override public function get lafPrefix():String
	{
		return "Box";
	}

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

	ui function contentGroupAdded():void
	{
		if (_layout != null)
		{
			contentGroup.layout = _layout;
		}

		contentGroup.subviews = _elements;
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