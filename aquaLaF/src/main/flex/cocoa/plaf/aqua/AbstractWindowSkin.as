package cocoa.plaf.aqua
{
import cocoa.Border;
import cocoa.Insets;
import cocoa.LabelHelper;
import cocoa.View;
import cocoa.layout.AdvancedLayout;
import cocoa.plaf.AbstractSkin;
import cocoa.plaf.BottomBarStyle;
import cocoa.plaf.WindowSkin;

import flash.display.DisplayObject;
import flash.display.Graphics;

import flash.events.MouseEvent;

import flash.text.engine.TextLine;

import mx.core.IFlexDisplayObject;
import mx.core.ILayoutElement;
import mx.core.mx_internal;
import mx.managers.IFocusManagerContainer;

use namespace mx_internal;

/**
 * http://developer.apple.com/mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGWindows/XHIGWindows.html
 *
 * IFocusManagerContainer нужен так как flex PopUpManager только в этом случае создаст focus manager для окна (а он нужен)
 */
public class AbstractWindowSkin extends AbstractSkin implements cocoa.plaf.WindowSkin, AdvancedLayout, IFocusManagerContainer
{
	[Embed(source="/Window.resizeGripper.png")]
	private static const resizeGripperClass:Class;

	private static const TITLE_BAR_HEIGHT:Number = 23; // вместе с 1px полосой внизу, которая визуально разделяет label bar от content pane
	protected static const BOTTOM_BAR_HEIGHT:Number = 47; // без нижней 1px полосы означающей drop shadow

	// http://developer.apple.com/mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGLayout/XHIGLayout.html
	protected static const CONTENT_INSETS:Insets = new Insets(0, TITLE_BAR_HEIGHT, 0, BOTTOM_BAR_HEIGHT);

	private var resizeGripper:DisplayObject;

	private var border:Border;

	private var labelHelper:LabelHelper;

	private static var mover:WindowMover;
	private static var resizer:WindowResizer;

	public function AbstractWindowSkin()
	{
		labelHelper = new LabelHelper(this);
	}

	public function set bottomBarStyle(value:BottomBarStyle):void
	{
	}

	protected var _contentView:View;
	public function set contentView(value:View):void
	{
		_contentView = value;
		if (initialized)
		{
			addChildAt(DisplayObject(_contentView), 0); 
		}
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
		border = laf.getBorder("Window.border");

		addChild(DisplayObject(_contentView));

		if (resizeGripper == null)
		{
			resizeGripper = new resizeGripperClass();
			addDisplayObject(resizeGripper);
		}

		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}

	private function mouseDownHandler(event:MouseEvent):void
	{
		if (event.target != this && !(event.target is TextLine))
		{
			return;
		}

		var mouseY:Number = event.localY;
		var mouseX:Number = event.localX;
		if (mouseY < 0 || mouseX < 0 || mouseX > width || mouseY > height || /* skip shadow */ (mouseY > CONTENT_INSETS.top && mouseY < (height - CONTENT_INSETS.bottom)))
		{
			return;
		}

		if (mouseX >= resizeGripper.x && mouseY >= resizeGripper.y)
		{
			if (resizer == null)
			{
				resizer = new WindowResizer();
			}
			resizer.resize(event, this);
		}
		else
		{
			if (mover == null)
			{
				mover = new WindowMover();
			}
			mover.move(event, this, TITLE_BAR_HEIGHT);
		}
	}

	public function childCanSkipMeasurement(element:ILayoutElement):Boolean
	{
		// если у окна установлен фиксированный размер, то content pane устанавливается в размер невзирая на его preferred
		return canSkipMeasurement();
	}

	override protected function measure():void
	{
		measuredMinWidth = Math.max(_contentView.minWidth);
		measuredMinHeight = CONTENT_INSETS.height + _contentView.minHeight;

		measuredWidth = Math.max(_contentView.getExplicitOrMeasuredWidth()) + CONTENT_INSETS.width;
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

		if (_contentView != null)
		{
			_contentView.move(CONTENT_INSETS.left, CONTENT_INSETS.top);
			_contentView.setActualSize(w - CONTENT_INSETS.width, h - CONTENT_INSETS.height);
		}

		resizeGripper.x = w - 11 - 4;
		resizeGripper.y = h - 11 - 4;
	}

	public function get defaultButton():IFlexDisplayObject
	{
		return null;
	}

	public function set defaultButton(value:IFlexDisplayObject):void
	{
	}
}
}