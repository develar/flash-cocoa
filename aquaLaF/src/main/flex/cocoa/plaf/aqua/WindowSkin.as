package cocoa.plaf.aqua
{
import cocoa.Border;
import cocoa.Insets;
import cocoa.LabelHelper;
import cocoa.UIManager;
import cocoa.dialog.Dialog;
import cocoa.plaf.WindowSkin;

import flash.display.Graphics;

import mx.core.ILayoutElement;
import mx.core.mx_internal;

import org.flyti.layout.AdvancedLayout;
import cocoa.AbstractSkin;
import cocoa.Container;
import cocoa.SkinPartProvider;
import cocoa.View;

import spark.layouts.HorizontalLayout;
import spark.layouts.VerticalAlign;

use namespace mx_internal;

/**
 * http://developer.apple.com/mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGWindows/XHIGWindows.html
 * На данный момент нет поддержки bottom bar как по спецификации Apple. Но есть нечто типа control bar как Open/Choose — явно там это так никак не названо.
 */
public class WindowSkin extends AbstractSkin implements cocoa.plaf.WindowSkin, AdvancedLayout, SkinPartProvider
{
	private var border:Border;

	private static const TITLE_BAR_HEIGHT:Number = 23; // вместе с 1px полосой внизу, которая визуально разделяет label bar от content pane
	private static const BOTTOM_BAR_HEIGHT:Number = 47; // без нижней 1px полосы означающей drop shadow

	private var labelHelper:LabelHelper;

	private var contentGroup:Container;
	private var controlBar:Container;

	// http://developer.apple.com/mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGLayout/XHIGLayout.html
	private static const WINDOW_CONTENT_INSETS:Insets = new Insets(0, TITLE_BAR_HEIGHT, 0, BOTTOM_BAR_HEIGHT);
	//noinspection JSUnusedLocalSymbols
	private static const DIALOG_CONTENT_INSETS:Insets = new Insets(20, TITLE_BAR_HEIGHT + 14, 20, BOTTOM_BAR_HEIGHT + 20);
	
	private var contentInsets:Insets;

	private var mover:WindowMover;

	public var hostComponent:Dialog;

	public function WindowSkin()
	{
		labelHelper = new LabelHelper(this, UIManager.getFont("SystemFont"));

		super();
	}

	override public function set untypedHostComponent(value:View):void
	{
		super.untypedHostComponent = value;

		var insetsStyle:String = value.getStyle("insets");
		contentInsets = insetsStyle == null || insetsStyle == "none" ? WINDOW_CONTENT_INSETS : cocoa.plaf.aqua.WindowSkin[insetsStyle.toUpperCase() + "_CONTENT_INSETS"];
		mover = new WindowMover(this, TITLE_BAR_HEIGHT, contentInsets);
	}

	override public function set styleName(value:Object):void
    {
		super.styleName = value;
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
		if (contentGroup == null)
		{
			contentGroup = new Container();
			addChild(contentGroup);
			hostComponent.skinPartAdded("contentGroup", contentGroup);
		}

		if (controlBar == null)
		{
			controlBar = new Container();

			var bottomBarGroupLayout:HorizontalLayout = new HorizontalLayout();
			bottomBarGroupLayout.verticalAlign = VerticalAlign.MIDDLE;
			bottomBarGroupLayout.paddingLeft = 21;
			bottomBarGroupLayout.paddingRight = 21;
			bottomBarGroupLayout.gap = 12;
			controlBar.layout = bottomBarGroupLayout;

			addChild(controlBar);
			hostComponent.skinPartAdded("controlBar", controlBar);
		}
	}

	public function childCanSkipMeasurement(element:ILayoutElement):Boolean
	{
		// если у окна установлен фиксированный размер, то content pane устанавливается в размер невзирая на его preferred
		return canSkipMeasurement();
	}

	override protected function measure():void
	{
		measuredMinWidth = Math.max(contentGroup.minWidth, controlBar.minWidth);
		measuredMinHeight = contentInsets.height + contentGroup.minHeight;

		measuredWidth = Math.max(contentGroup.getExplicitOrMeasuredWidth(), controlBar.getExplicitOrMeasuredWidth()) + contentInsets.width;
		measuredHeight = contentInsets.height + contentGroup.getExplicitOrMeasuredHeight();
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

		contentGroup.move(contentInsets.left, contentInsets.top);
		contentGroup.setActualSize(w - contentInsets.width, h - contentInsets.height);

		var controlBarGroupWidth:Number = controlBar.getExplicitOrMeasuredWidth();
		controlBar.move(w - controlBarGroupWidth, h - BOTTOM_BAR_HEIGHT);
		controlBar.setActualSize(controlBarGroupWidth, BOTTOM_BAR_HEIGHT);
	}
}
}