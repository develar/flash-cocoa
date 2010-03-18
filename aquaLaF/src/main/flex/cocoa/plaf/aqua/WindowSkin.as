package cocoa.plaf.aqua
{
import cocoa.Border;
import cocoa.BorderedContainer;
import cocoa.Insets;
import cocoa.LabelHelper;
import cocoa.UIPartProvider;
import cocoa.View;
import cocoa.dialog.Dialog;
import cocoa.layout.AdvancedLayout;
import cocoa.plaf.AbstractSkin;
import cocoa.plaf.BottomBarStyle;
import cocoa.plaf.WindowSkin;

import flash.display.DisplayObject;
import flash.display.Graphics;

import mx.core.ILayoutElement;
import mx.core.mx_internal;

import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalAlign;

use namespace mx_internal;

/**
 * http://developer.apple.com/mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGWindows/XHIGWindows.html
 * На данный момент нет поддержки bottom bar как по спецификации Apple. Но есть нечто типа control bar как Open/Choose — явно там это так никак не названо.
 */
public class WindowSkin extends AbstractSkin implements cocoa.plaf.WindowSkin, AdvancedLayout
{
	[Embed(source="/Window.resizeGripper.png")]
	private static const resizeGripperClass:Class;

	private var resizeGripper:DisplayObject;

	private var border:Border;

	private static const TITLE_BAR_HEIGHT:Number = 23; // вместе с 1px полосой внизу, которая визуально разделяет label bar от content pane
	private static const BOTTOM_BAR_HEIGHT:Number = 47; // без нижней 1px полосы означающей drop shadow

	private var labelHelper:LabelHelper;

	private var controlBar:BorderedContainer;

	// http://developer.apple.com/mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGLayout/XHIGLayout.html
	private static const CONTENT_INSETS:Insets = new Insets(0, TITLE_BAR_HEIGHT, 0, BOTTOM_BAR_HEIGHT);

	private var mover:WindowMover;

	public var hostComponent:Dialog;

	public function WindowSkin()
	{
		labelHelper = new LabelHelper(this);
	}

	private var _contentView:View;
	public function set contentView(value:View):void
	{
		_contentView = value;
	}

	private var _bottomBarStyle:BottomBarStyle;
	public function set bottomBarStyle(value:BottomBarStyle):void
	{
		_bottomBarStyle = value;
	}

	private var _title:String;
	public function set title(value:String):void
	{
		if (value == _title)
		{
			return;
		}

		_title = value;
		labelHelper.text = _title;

		invalidateDisplayList();
	}

	override protected function createChildren():void
	{
		super.createChildren();

		labelHelper.font = getFont("SystemFont");
		mover = new WindowMover(this, TITLE_BAR_HEIGHT, CONTENT_INSETS);
		border = laf.getBorder("Window.border");

		addChild(DisplayObject(_contentView));

		if (resizeGripper == null)
		{
			resizeGripper = new resizeGripperClass();
			addDisplayObject(resizeGripper);
		}

		if (controlBar == null)
		{
			controlBar = new BorderedContainer();
			controlBar.height = BOTTOM_BAR_HEIGHT;
			controlBar.laf = AquaLookAndFeel(laf).createWindowFrameLookAndFeel();
			controlBar.border = laf.getBorder("Window.bottomBar." + _bottomBarStyle.name);

			var bottomBarGroupLayout:HorizontalLayout = new HorizontalLayout();
			bottomBarGroupLayout.verticalAlign = VerticalAlign.MIDDLE;
			bottomBarGroupLayout.paddingLeft = 21;
			bottomBarGroupLayout.paddingRight = 21;
			bottomBarGroupLayout.gap = 12;
			controlBar.layout = bottomBarGroupLayout;

			hostComponent.uiPartAdded("controlBar", controlBar);
			addChild(controlBar);
		}
	}

	public function childCanSkipMeasurement(element:ILayoutElement):Boolean
	{
		// если у окна установлен фиксированный размер, то content pane устанавливается в размер невзирая на его preferred
		return canSkipMeasurement();
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
		var g:Graphics = graphics;
		g.clear();

		if (_title != null)
		{
			labelHelper.validate();
			labelHelper.moveToCenter(w, 16);
		}

		border.draw(this, g, w, h);

		_contentView.move(CONTENT_INSETS.left, CONTENT_INSETS.top);
		_contentView.setActualSize(w - CONTENT_INSETS.width, h - CONTENT_INSETS.height);

		var controlBarGroupWidth:Number = controlBar.getExplicitOrMeasuredWidth();
		controlBar.move(w - controlBarGroupWidth, h - BOTTOM_BAR_HEIGHT);
		controlBar.setActualSize(controlBarGroupWidth, BOTTOM_BAR_HEIGHT);

//		var offset:Number = 1;
		var offset:Number = 4; 
		resizeGripper.x = w - 11 - offset;
		resizeGripper.y = h - 11 - offset;
	}
}
}