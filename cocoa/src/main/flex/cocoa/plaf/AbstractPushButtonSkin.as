package cocoa.plaf
{
import cocoa.AbstractButton;
import cocoa.Border;
import cocoa.Icon;
import cocoa.LabelHelper;
import cocoa.UIManager;

import flash.display.Graphics;
import flash.text.engine.ElementFormat;

public class AbstractPushButtonSkin extends AbstractSkin implements PushButtonSkin
{
	protected var labelHelper:LabelHelper;
	protected var border:Border;

	public var hostComponent:AbstractButton;

	public function AbstractPushButtonSkin()
	{
		super();

		mouseChildren = false;
		labelHelper = new LabelHelper(this, getFont("SystemFont"));
	}

	override public function regenerateStyleCache(recursive:Boolean):void
    {
		border = getBorder("border");
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

	protected function getFont(key:String):ElementFormat
	{
		return UIManager.getFont(key);
	}

	protected function getBorder(key:String):Border
	{
		return UIManager.getBorder(hostComponent.stylePrefix + "." + key);
	}

	protected function getIcon(key:String):Icon
	{
		return UIManager.getIcon(hostComponent.stylePrefix + "." + key);
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
}
}