package cocoa
{
import flash.events.Event;
import flash.utils.Dictionary;

import spark.layouts.supportClasses.LayoutBase;

use namespace ui;

[DefaultProperty("mxmlContent")]
public class Box extends AbstractComponent implements ViewContainerProvider
{
	protected static const _skinParts:Dictionary = new Dictionary();
	_skinParts.contentGroup = 0;
	override protected function get skinParts():Dictionary
	{
		return _skinParts;
	}

	ui var contentGroup:Container;

	public function Box()
	{
		super();

		listenResourceChange();
	}

	private var _elements:Array;

	override protected function get defaultLaFPrefix():String
	{
		return "Box";
	}

	public function set mxmlContent(value:Array):void
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

	[Bindable(event="lChanged")]
	public function l(key:String):String
	{
		return _resourceBundle == null ? null : resourceManager.getString(_resourceBundle, key);
	}

	override protected function resourcesChanged():void
    {
    	dispatchEvent(new Event("lChanged"));
	}

	public function get viewContainer():ViewContainer
	{
		return contentGroup;
	}
}
}