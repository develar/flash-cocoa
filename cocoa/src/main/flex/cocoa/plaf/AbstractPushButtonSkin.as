package cocoa.plaf
{
import cocoa.Border;
import cocoa.Button;
import cocoa.Component;
import cocoa.LabelHelper;

import flash.display.Graphics;

public class AbstractPushButtonSkin extends AbstractSkin implements PushButtonSkin
{
	protected var labelHelper:LabelHelper;
	protected var border:Border;

	protected var myComponent:Button;

	public function AbstractPushButtonSkin()
	{
		super();

		mouseChildren = false;
		labelHelper = new LabelHelper(this);
	}

	override public function attach(component:Component, laf:LookAndFeel):void
	{
		super.attach(component, laf);
		myComponent = Button(component);
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

	override protected function createChildren():void
	{
		super.createChildren();

		labelHelper.font = getFont("SystemFont");
		border = getBorder("border");
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
		labelHelper.font = getFont(enabled ? "SystemFont" : "SystemFont.disabled");
		labelHelper.validate();
		labelHelper.moveByInsets(h, border.contentInsets, border.frameInsets);

		var g:Graphics = graphics;
		g.clear();
		border.draw(this, g, w, h);
	}

	override public function set enabled(value:Boolean):void
	{
		super.enabled = value;

		mouseEnabled = value;
	}
}
}