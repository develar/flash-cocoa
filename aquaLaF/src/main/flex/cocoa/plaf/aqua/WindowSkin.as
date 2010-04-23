package cocoa.plaf.aqua
{
import cocoa.BorderedContainer;
import cocoa.layout.AdvancedLayout;
import cocoa.plaf.BottomBarStyle;
import cocoa.plaf.WindowSkin;

import mx.core.mx_internal;

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

			var bottomBarGroupLayout:BottomBarLayout = new BottomBarLayout();
			bottomBarGroupLayout.padding = 20;
			bottomBarGroupLayout.gap = _bottomBarStyle == BottomBarStyle.application ? 8 : 12;
			controlBar.layout = bottomBarGroupLayout;

			component.uiPartAdded("controlBar", controlBar);
			addChildAt(controlBar, 0);
		}
	}

	override protected function measure():void
	{
//		measuredMinWidth = Math.max(_contentView.minWidth, controlBar.minWidth);
		measuredMinWidth = _contentView.minWidth;
		measuredMinHeight = contentInsets.height + _contentView.minHeight;

//		measuredWidth = Math.max(_contentView.getExplicitOrMeasuredWidth(), controlBar.getExplicitOrMeasuredWidth()) + CONTENT_INSETS.width;
		measuredWidth = _contentView.getExplicitOrMeasuredWidth() + contentInsets.width;
		measuredHeight = contentInsets.height + _contentView.getExplicitOrMeasuredHeight();
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		controlBar.y = h - BOTTOM_BAR_HEIGHT;
		controlBar.setActualSize(w, BOTTOM_BAR_HEIGHT);
	}
}
}