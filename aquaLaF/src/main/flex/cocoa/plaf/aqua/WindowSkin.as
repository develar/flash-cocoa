package cocoa.plaf.aqua
{
import cocoa.BorderedContainer;
import cocoa.layout.AdvancedLayout;
import cocoa.plaf.BottomBarStyle;
import cocoa.plaf.WindowSkin;

import mx.core.mx_internal;

import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalAlign;

use namespace mx_internal;

/**
 * http://developer.apple.com/mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGWindows/XHIGWindows.html
 * На данный момент нет поддержки bottom bar как по спецификации Apple. Но есть нечто типа control bar как Open/Choose — явно там это так никак не названо.
 */
public class WindowSkin extends AbstractWindowSkin implements cocoa.plaf.WindowSkin, AdvancedLayout
{
	private var controlBar:BorderedContainer;

	private var _bottomBarStyle:BottomBarStyle;
	override public function set bottomBarStyle(value:BottomBarStyle):void
	{
		_bottomBarStyle = value;
	}

	override protected function createChildren():void
	{
		super.createChildren();

		if (controlBar == null)
		{
			controlBar = new BorderedContainer();
			controlBar.height = BOTTOM_BAR_HEIGHT;
			controlBar.laf = AquaLookAndFeel(laf).createWindowFrameLookAndFeel();
			controlBar.border = laf.getBorder("Window.bottomBar." + _bottomBarStyle.name);
			controlBar.mouseEnabled = false;

			var bottomBarGroupLayout:HorizontalLayout = new HorizontalLayout();
			bottomBarGroupLayout.verticalAlign = VerticalAlign.MIDDLE;
			bottomBarGroupLayout.paddingLeft = 21;
			bottomBarGroupLayout.paddingRight = 21;
			bottomBarGroupLayout.gap = 12;
			controlBar.layout = bottomBarGroupLayout;

			component.uiPartAdded("controlBar", controlBar);
			addChild(controlBar);
		}
	}

	override protected function measure():void
	{
		measuredMinWidth = Math.max(_contentView.minWidth, controlBar.minWidth);
		measuredMinHeight = CONTENT_INSETS.height + _contentView.minHeight;

		measuredWidth = Math.max(_contentView.getExplicitOrMeasuredWidth(), controlBar.getExplicitOrMeasuredWidth()) + CONTENT_INSETS.width;
		measuredHeight = CONTENT_INSETS.height + _contentView.getExplicitOrMeasuredHeight();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		var controlBarGroupWidth:Number = controlBar.getExplicitOrMeasuredWidth();
		controlBar.move(w - controlBarGroupWidth, h - BOTTOM_BAR_HEIGHT);
		controlBar.setActualSize(controlBarGroupWidth, BOTTOM_BAR_HEIGHT);
	}
}
}