package cocoa.plaf
{
import cocoa.Border;
import cocoa.HighlightableItemRenderer;
import cocoa.Icon;
import cocoa.LabelHelper;
import cocoa.MenuItem;

import flash.display.Graphics;

public class MenuItemRenderer extends AbstractItemRenderer implements HighlightableItemRenderer
{	
	protected var labelHelper:LabelHelper;
	protected var border:Border;

	public function MenuItemRenderer()
	{
		labelHelper = new LabelHelper(this);
		mouseChildren = false;
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

	protected function getBorder(key:String):Border
	{
		return _laf.getBorder("MenuItem." + key);
	}

	protected function getIcon(key:String):Icon
	{
		return _laf.getIcon("MenuItem." + key);
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

	override public function set laf(value:LookAndFeel):void
	{
		super.laf = value;
		labelHelper.font = getFont("SystemFont");
	}

	override protected function measure():void
	{
		measuredMinHeight = measuredHeight = border.layoutHeight;

		if (labelHelper.hasText)
		{
			labelHelper.validate();
			measuredMinWidth = measuredWidth = Math.round(labelHelper.textWidth) + border.contentInsets.width;
		}
		else
		{
			measuredMinWidth = measuredWidth = 0;
		}
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