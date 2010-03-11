package cocoa.plaf
{
import cocoa.Border;
import cocoa.LabelHelper;
import cocoa.MenuItem;

import flash.display.Graphics;

public class MenuItemRenderer extends AbstractItemRenderer
{	
	protected var labelHelper:LabelHelper;
	protected var border:Border;

	public function MenuItemRenderer()
	{
		addRollHandlers();
	}

	public function get labelLeftMargin():Number
	{
		return border.contentInsets.left;
	}

	override public function get baselinePosition():Number
	{
		return border.layoutHeight - border.contentInsets.bottom;
	}

	override public function get label():String
	{
		return labelHelper.text;
	}

	override public function set label(value:String):void
	{
		if (value == labelHelper.text)
		{
			return;
		}

		labelHelper.text = value;

		invalidateSize();
		invalidateDisplayList();
	}

	protected var menuItem:MenuItem;
	override public function get data():Object
	{
		return menuItem;
	}
	override public function set data(value:Object):void
	{
		menuItem = MenuItem(value);
	}

	override protected function measure():void
	{
		if (!labelHelper.hasText)
		{
			return;
		}

		labelHelper.validate();

		measuredMinWidth = measuredWidth = Math.round(labelHelper.textWidth) + border.contentInsets.width;
		measuredMinHeight = measuredHeight = border.layoutHeight;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		labelHelper.validate();
		labelHelper.moveByInset(h, border.contentInsets);
		
		var g:Graphics = graphics;
		g.clear();

		border.draw(this, g, w, h);
	}
}
}