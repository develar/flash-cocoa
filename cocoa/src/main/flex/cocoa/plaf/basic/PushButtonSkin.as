package cocoa.plaf.basic
{
import cocoa.AbstractButton;
import cocoa.Border;
import cocoa.Component;
import cocoa.Insets;
import cocoa.LabelHelper;
import cocoa.TextInsets;
import cocoa.layout.LayoutMetrics;
import cocoa.plaf.AbstractSkin;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.PushButtonSkin;

import flash.display.Graphics;

import mx.managers.IFocusManagerComponent;

public class PushButtonSkin extends AbstractSkin implements cocoa.plaf.PushButtonSkin, IFocusManagerComponent
{
	protected var labelHelper:LabelHelper;
	protected var border:Border;

	protected var myComponent:AbstractButton;

	public function PushButtonSkin()
	{
		super();

		mouseChildren = false;
	}

	protected function get bordered():Boolean
	{
		return true;
	}

	override public function attach(component:Component, laf:LookAndFeel):void
	{
		super.attach(component, laf);
		
		myComponent = AbstractButton(component);
	}

	override public function get baselinePosition():Number
	{
		return border.layoutHeight - border.contentInsets.bottom;
	}

	public function set label(value:String):void
	{
		if (labelHelper == null)
		{
			if (value == null)
			{
				return;
			}

			labelHelper = new LabelHelper(this, laf == null ? null : getFont("SystemFont"));
		}
		else if (value == labelHelper.text)
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

		if (labelHelper != null)
		{
			labelHelper.font = getFont("SystemFont");
		}

		if (bordered)
		{
			border = getBorder("border");
		}

		adjustTitleWidth();
	}

	override protected function measure():void
	{
		if (labelHelper == null || !labelHelper.hasText)
		{
			return;
		}

		labelHelper.validate();

		measuredMinWidth = measuredWidth = Math.round(labelHelper.textWidth) + border.contentInsets.width;
		measuredMinHeight = measuredHeight = border.layoutHeight;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		if (labelHelper != null)
		{
			labelHelper.font = getFont(enabled ? "SystemFont" : "SystemFont.disabled");
			labelHelper.validate();
			labelHelper.moveByInsets(h, border.contentInsets, border.frameInsets);
		}

		var g:Graphics = graphics;
		g.clear();
		border.draw(this, g, w, h);
	}

	override public function set enabled(value:Boolean):void
	{
		super.enabled = value;

		mouseEnabled = value;
	}

	override public function set explicitWidth(value:Number):void
	{
		super.explicitWidth = value;
		adjustTitleWidth();
	}

	override public function set layoutMetrics(value:LayoutMetrics):void
	{
		super.layoutMetrics = value;
		adjustTitleWidth();
	}

	private function adjustTitleWidth():void
	{
		if (border != null && labelHelper != null)
		{
			var titleInsets:Insets = border.contentInsets;
			labelHelper.adjustWidth(_layoutMetrics.width - titleInsets.left - (titleInsets is TextInsets ? TextInsets(titleInsets).truncatedTailMargin : titleInsets.right));
		}
	}

	public function drawFocus(isFocused:Boolean):void
	{
	}
}
}