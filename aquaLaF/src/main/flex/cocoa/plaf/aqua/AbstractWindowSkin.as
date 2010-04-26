package cocoa.plaf.aqua
{
import cocoa.Border;
import cocoa.Insets;
import cocoa.LabelHelper;
import cocoa.Toolbar;
import cocoa.View;
import cocoa.layout.AdvancedLayout;
import cocoa.plaf.AbstractSkin;
import cocoa.plaf.BottomBarStyle;
import cocoa.plaf.WindowSkin;

import cocoa.ui;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.events.MouseEvent;
import flash.text.engine.TextLine;

import mx.core.IFlexDisplayObject;
import mx.core.ILayoutElement;
import mx.core.mx_internal;
import mx.managers.IFocusManagerContainer;

use namespace mx_internal;
use namespace ui;

/**
 * http://developer.apple.com/mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGWindows/XHIGWindows.html
 *
 * IFocusManagerContainer нужен так как flex PopUpManager только в этом случае создаст focus manager для окна (а он нужен)
 */
public class AbstractWindowSkin extends AbstractSkin implements cocoa.plaf.WindowSkin, AdvancedLayout, IFocusManagerContainer
{
	[Embed(source="/Window.resizeGripper.png")]
	private static const resizeGripperClass:Class;

	private static const TITLE_BAR_HEIGHT:Number = 21;
	protected static const BOTTOM_BAR_HEIGHT:Number = 47;
	protected static const TOOLBAR_SMALL_HEIGHT:Number = 47;

	// http://developer.apple.com/mac/library/documentation/UserExperience/Conceptual/AppleHIGuidelines/XHIGLayout/XHIGLayout.html
	private static const CONTENT_INSETS:Insets = new Insets(0, TITLE_BAR_HEIGHT, 0, BOTTOM_BAR_HEIGHT);

	protected static const CONTENT_INSETS_TOOLBAR:Insets = new Insets(0, TITLE_BAR_HEIGHT + TOOLBAR_SMALL_HEIGHT, 0, BOTTOM_BAR_HEIGHT);

	private var resizeGripper:DisplayObject;

	private var border:Border;

	private var labelHelper:LabelHelper;

	private static var mover:WindowMover;
	private static var resizer:WindowResizer;

	public function AbstractWindowSkin()
	{
		labelHelper = new LabelHelper(this);
	}

	protected function get contentInsets():Insets
	{
		return _toolbar == null ? CONTENT_INSETS : CONTENT_INSETS_TOOLBAR;
	}

	public function set bottomBarStyle(value:BottomBarStyle):void
	{
	}

	protected var _toolbar:Toolbar;
	public function set toolbar(value:Toolbar):void
	{
		_toolbar = value;
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

		if (_toolbar == null)
		{
			border = laf.getBorder("Window.border");
		}
		else
		{
			border = laf.getBorder("Window.border.smallToolbar");
			var toolbarSkin:DisplayObject = DisplayObject(_toolbar.createView(laf));
			toolbarSkin.y = TITLE_BAR_HEIGHT;
			toolbarSkin.height = TOOLBAR_SMALL_HEIGHT;
			addChild(toolbarSkin);
		}
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
		if (mouseY < 0 || mouseX < 0 || mouseX > width || mouseY > height || /* skip shadow */ (mouseY > contentInsets.top && mouseY < (height - contentInsets.bottom)))
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
		measuredMinHeight = contentInsets.height + _contentView.minHeight;

		measuredWidth = Math.max(_contentView.getExplicitOrMeasuredWidth()) + contentInsets.width;
		measuredHeight = contentInsets.height + _contentView.getExplicitOrMeasuredHeight();
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

		border.draw(this, g, w, h - BOTTOM_BAR_HEIGHT);

		// линия отделяющая контент от title/tool bar
		g.lineStyle(1, 0x515151);
		g.moveTo(0, contentInsets.top);
		g.lineTo(w, contentInsets.top);

		if (_toolbar != null)
		{
			_toolbar.skin.setActualSize(w, TOOLBAR_SMALL_HEIGHT);
		}

		_contentView.move(contentInsets.left, contentInsets.top);
		_contentView.setActualSize(w - contentInsets.width, h - contentInsets.height);

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