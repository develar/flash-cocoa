package cocoa.plaf
{
import cocoa.Border;
import cocoa.FrameInsets;
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

// border может указать layoutWidth/layoutHeight как отрицательные — некий компонент может интерпретировать это как в процентах (то есть -50 это 50%), а не в px
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