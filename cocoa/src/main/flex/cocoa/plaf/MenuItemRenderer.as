package cocoa.plaf
{
import cocoa.MenuItem;

import flash.display.Graphics;

public class MenuItemRenderer extends LabeledItemRenderer
{
	public function get labelLeftMargin():Number
	{
		return border.contentInsets.left;
	}

	override public function get lafPrefix():String
	{
		return "MenuItem";
	}

	protected var menuItem:Object;
	override public function get data():Object
	{
		return menuItem;
	}
	override public function set data(value:Object):void
	{
		var isSeparatorItem:Boolean = false;
		menuItem = value;
		if (menuItem is MenuItem)
		{
			enabled = mouseEnabled = MenuItem(menuItem).enabled;
			isSeparatorItem = MenuItem(menuItem).isSeparatorItem;
		}
		else
		{
			enabled = mouseEnabled = true;
		}

		border = getBorder(isSeparatorItem ? "separatorBorder" : "border");

		invalidateSize();
		invalidateDisplayList();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		const highlighted:Boolean = (state & HIGHLIGHTED) != 0;
		if (!(menuItem is MenuItem && MenuItem(menuItem).isSeparatorItem))
		{
			border = getBorder(highlighted ? "border.highlighted" : "border");
		}

		labelHelper.font = getFont(highlighted ? "SystemFont.highlighted" : "SystemFont");
		labelHelper.validate();
		labelHelper.moveByInset(h, border.contentInsets);
		
		var g:Graphics = graphics;
		g.clear();

		border.draw(this, g, w, h);
	}
}
}