package cocoa.plaf
{
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

public class AbstractBorder implements Border
{
	protected static const EMPTY_FRAME_INSETS:FrameInsets = new FrameInsets();
	protected static const EMPTY_CONTENT_INSETS:Insets = new Insets();

	public function get layoutHeight():Number
	{
		return NaN;
	}

	public function get layoutWidth():Number
	{
		return NaN;
	}

	protected var _frameInsets:FrameInsets = EMPTY_FRAME_INSETS;
	public function get frameInsets():FrameInsets
	{
		return _frameInsets;
	}

	protected var _contentInsets:Insets = EMPTY_CONTENT_INSETS;
	public function get contentInsets():Insets
	{
		return _contentInsets;
	}

	public function draw(view:View, g:Graphics, w:Number, h:Number):void
	{
		throw new Error("abstract");
	}
}
}