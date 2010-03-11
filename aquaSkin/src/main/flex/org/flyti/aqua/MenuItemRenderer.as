package org.flyti.aqua
{
import flash.display.Graphics;

import org.flyti.view.AbstractItemRenderer;
import org.flyti.view.LabelHelper;
import org.flyti.view.ListItemRendererBorder;

public class MenuItemRenderer extends AbstractItemRenderer
{	
	private var labelHelper:LabelHelper;
	private var border:ListItemRendererBorder;

	public function MenuItemRenderer()
	{
		labelHelper = new LabelHelper(this, AquaFonts.SYSTEM_FONT);

		addRollHandlers();
		border = AquaBorderFactory.getMenuItemBorder();
	}

	public function get labelLeftMargin():Number
	{
		return border.textInsets.left;
	}

	override public function get baselinePosition():Number
	{
		return border.layoutHeight - border.textInsets.bottom;
	}

	override public function get label():String
	{
		return null;
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

	private var _data:Object;
	override public function get data():Object
	{
		return _data;
	}
	override public function set data(value:Object):void
	{
		_data = value;
	}

	override protected function measure():void
	{
		if (!labelHelper.hasText)
		{
			return;
		}

		labelHelper.validate();

		measuredMinWidth = measuredWidth =  Math.round(labelHelper.textWidth) + border.textInsets.width;
		measuredMinHeight = measuredHeight = border.layoutHeight;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		labelHelper.font = ((state & HOVERED) == 0) ? AquaFonts.SYSTEM_FONT : AquaFonts.SYSTEM_FONT_WHITE;
		labelHelper.validate();
		labelHelper.moveByInset(h, border.textInsets);
		
		var g:Graphics = graphics;
		g.clear();

		border.draw(this, g, w, h, state);
	}
}
}