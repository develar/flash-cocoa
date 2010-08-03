package cocoa.plaf.aqua
{
import cocoa.BorderedContainer;
import cocoa.Insets;
import cocoa.plaf.basic.BottomBarStyle;
import cocoa.plaf.DialogSkin;

import mx.core.mx_internal;

use namespace mx_internal;

/**
 * http://developer.apple.com/mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGWindows/XHIGWindows.html
 * На данный момент нет поддержки bottom bar как по спецификации Apple. Но есть нечто типа control bar как Open/Choose — явно там это так никак не названо.
 */
public class WindowSkin extends AbstractWindowSkin implements DialogSkin
{
	private static const CONTENT_LAYOUT_INSETS:Insets = new Insets(20, 14, 20,  20);
	private static const CONTENT_LAYOUT_INSETS_BOTTOM_BAR:Insets = new Insets(20, 14, 20, 12);

	private var controlBar:BorderedContainer;

	private var _bottomBarStyle:BottomBarStyle;
	public function set bottomBarStyle(value:BottomBarStyle):void
	{
		_bottomBarStyle = value;
	}

	override protected function get contentLayoutInsets():Insets
	{
		return _useWindowGap ? (_bottomBarStyle == null ? CONTENT_LAYOUT_INSETS : CONTENT_LAYOUT_INSETS_BOTTOM_BAR) : super.contentLayoutInsets;
	}

	override protected function createChildren():void
	{
		super.createChildren();

		if (controlBar == null)
		{
			controlBar = new BorderedContainer();
			controlBar.height = BOTTOM_BAR_HEIGHT;
			controlBar.laf = _bottomBarStyle == BottomBarStyle.application ? AquaLookAndFeel(laf).createWindowFrameLookAndFeel() : laf;
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
		measuredMinHeight = insetsHeight + _contentView.minHeight;

//		measuredWidth = Math.max(_contentView.getExplicitOrMeasuredWidth(), controlBar.getExplicitOrMeasuredWidth()) + CONTENT_INSETS.width;
		measuredWidth = _contentView.getExplicitOrMeasuredWidth() + insetsWidth;
		measuredHeight = _contentView.getExplicitOrMeasuredHeight() + insetsHeight;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		super.updateDisplayList(w, h);

		controlBar.y = h - BOTTOM_BAR_HEIGHT;
		controlBar.setActualSize(w, BOTTOM_BAR_HEIGHT);
	}

	override protected function get hasBottomBar():Boolean
	{
		return true;
	}
}
}