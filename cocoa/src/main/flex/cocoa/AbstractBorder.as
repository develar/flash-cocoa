package cocoa
{
import flash.display.Graphics;

import mx.core.UIComponent;

public class AbstractBorder implements Border
{
	private static const EMPTY_FRAME_INSETS:FrameInsets = new FrameInsets();
	private static const EMPTY_INSETS:Insets = new Insets();

	public function get layoutHeight():Number
	{
		return NaN;
	}

	protected var _frameInsets:FrameInsets = EMPTY_FRAME_INSETS;
	public function get frameInsets():FrameInsets
	{
		return _frameInsets;
	}

	protected var _contentInsets:Insets = EMPTY_INSETS;
	public function get contentInsets():Insets
	{
		return _contentInsets;
	}

	public function draw(object:UIComponent, g:Graphics, w:Number, h:Number):void
	{
		throw new Error("abstract");
	}
}
}