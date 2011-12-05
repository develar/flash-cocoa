package cocoa
{
import flash.display.DisplayObject;

import mx.core.IFlexDisplayObject;

import spark.core.SpriteVisualElement;

public class EmbeddedImage extends SpriteVisualElement
{
	public function EmbeddedImage()
	{
	}

	private var _source:DisplayObject;
	public function set source(value:IFlexDisplayObject):void
	{
		width = value.width;
		height = value.height;
 
		if (_source != null)
		{
			removeChildAt(0);
		}

		_source = DisplayObject(value);
		addChild(_source);
	}
}
}