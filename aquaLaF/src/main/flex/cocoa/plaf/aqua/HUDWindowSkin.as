package cocoa.plaf.aqua
{
import cocoa.Component;
import cocoa.Insets;
import cocoa.View;
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;

import flash.display.Graphics;

public class HUDWindowSkin extends AbstractWindowSkin
{
	private static const TITLE_BAR_HEIGHT:Number = 19;
	private static const CONTENT_INSETS:Insets = new Insets(15, TITLE_BAR_HEIGHT + 14, 15, 15);

	override public function attach(component:Component, laf:LookAndFeel):void
	{
		super.attach(component, AquaLookAndFeel(laf).createHUDLookAndFeel());
	}

	override protected function drawTitleBottomBorderLine(g:Graphics, w:Number):void
	{
		// skip
	}

	override protected function get contentInsets():Insets
	{
		return CONTENT_INSETS;
	}

	override protected function get titleBarHeight():Number
	{
		return TITLE_BAR_HEIGHT;
	}

	override protected function get titleY():Number
	{
		return 14;
	}

	override public function set contentView(value:View):void
	{
		super.contentView = value;
		if (value is LookAndFeelProvider)
		{
			LookAndFeelProvider(value).laf = laf;
		}
		value.mouseEnabled = false; // контейнеру не нужно быть mouseEnabled — это помешает перемещать окно (HUD окно таскается не только за хром, но и за все, где не перекрывается content view controls)
	}

	override protected function get mouseDownOnContentViewCanMoveWindow():Boolean
	{
		return true;
	}

	override protected function createChildren():void
	{
		super.createChildren();
	}
}
}