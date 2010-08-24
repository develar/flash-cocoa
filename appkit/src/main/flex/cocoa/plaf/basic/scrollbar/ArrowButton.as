package cocoa.plaf.basic.scrollbar
{
import cocoa.FlexButton;
import cocoa.VScrollBar;
import cocoa.plaf.LookAndFeel;

import flash.events.Event;
import flash.events.MouseEvent;

internal final class ArrowButton extends FlexButton
{
	private var laf:LookAndFeel;
	private var styleKey:String;

	public function attach(laf:LookAndFeel, styleKey:String):void
	{
		this.laf = laf;
		this.styleKey = styleKey;

		_border = laf.getBorder(styleKey);
	}

	override protected function mouseEventHandler(event:Event):void
	{
		var mouseEvent:MouseEvent = MouseEvent(event);
		if (event.type == MouseEvent.ROLL_OUT || event.type == MouseEvent.ROLL_OVER)
		{
			if (mouseCaptured)
			{
				super.mouseEventHandler(event);
			}
		}
		else if (mouseEvent.localX >= 0 && mouseEvent.localX <= width)
		{
			if (mouseEvent.localY < 0)
			{
				VScrollBar(parent.parent)._trackMouseDownHandler(mouseEvent);
			}
			else if (mouseEvent.localY <= height)
			{
				super.mouseEventHandler(event);
			}
		}
	}

	override public function invalidateSkinState():void
	{
		if (laf != null)
		{
			_border = laf.getBorder((mouseCaptured && hovered) ? (styleKey + ".highlighted") : styleKey);
			invalidateDisplayList();
		}
	}
}
}