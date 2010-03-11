package org.flyti.aqua
{
import cocoa.Border;
import cocoa.LabelHelper;

import org.flyti.view.LightUIComponent;
import org.flyti.view.PushButtonSkin;

public class AbstractPushButtonSkin extends LightUIComponent implements PushButtonSkin
{
	protected var labelHelper:LabelHelper;
	protected var border:Border;

	public function AbstractPushButtonSkin()
	{
		super();

		mouseChildren = false;
		labelHelper = new LabelHelper(this, AquaFonts.SYSTEM_FONT);
	}

	override public function get baselinePosition():Number
	{
		return border.layoutHeight - border.contentInsets.bottom;
	}

	public function set label(value:String):void
	{
		if (value == labelHelper.text)
		{
			return;
		}

		labelHelper.text = value;

		invalidateSize();
		invalidateDisplayList();
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
}
}