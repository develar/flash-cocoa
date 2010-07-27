package cocoa.plaf.basic
{
import cocoa.Icon;
import cocoa.Insets;
import cocoa.plaf.IconButtonSkin;

import flash.display.Graphics;

public class IconButtonSkin extends PushButtonSkin implements cocoa.plaf.IconButtonSkin
{
	protected var _icon:Icon;
	public function set icon(value:Icon):void
	{
		_icon = value;
		invalidateDisplayList();
	}

	override protected function get bordered():Boolean
	{
		return false;
	}

	protected function get iconInsets():Insets
	{
		throw new Error("abstract");
	}

	protected function get labelInsets():Insets
	{
		throw new Error("abstract");
	}

	protected function measureIcon():void
	{
		measuredWidth = iconInsets.width;
		measuredHeight = iconInsets.height;
		if (_icon != null)
		{
			measuredWidth += _icon.iconWidth;
			measuredHeight += _icon.iconHeight;
		}
	}

	override protected function measure():void
	{
		measureIcon();

		if (labelHelper != null)
		{
			labelHelper.validate();
			var widthExcess:Number = (Math.round(labelHelper.textWidth) + labelInsets.width) - measuredWidth;
			if (widthExcess > 0)
			{
				measuredWidth += widthExcess;
			}
		}
	}

	protected function drawBorder(g:Graphics, w:Number, h:Number):void
	{
		// for mouse events
		g.beginFill(0, 0);
		g.drawRect(0, 0, w, h);
		g.endFill();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var g:Graphics = graphics;
		g.clear();

		drawBorder(g, w, h);
		if (_icon != null)
		{
			_icon.draw(this, g, Math.round((w - _icon.iconWidth) * 0.5), labelHelper == null ? Math.round((h - _icon.iconHeight) * 0.5) : iconInsets.top);
		}

		if (labelHelper != null)
		{
			labelHelper.moveToCenter(w, labelInsets.top);
		}
	}

	override public function set enabled(value:Boolean):void
	{
		if (value != enabled)
		{
			super.enabled = value;
			alpha = value ? 1 : 0.5;
		}
	}
}
}