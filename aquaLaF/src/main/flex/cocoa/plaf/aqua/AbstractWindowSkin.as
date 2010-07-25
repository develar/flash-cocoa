package cocoa.plaf.aqua
{
import cocoa.Border;
import cocoa.Insets;
import cocoa.LabelHelper;
import cocoa.PushButton;
import cocoa.Toolbar;
import cocoa.View;
import cocoa.Window;
import cocoa.layout.AdvancedLayout;
import cocoa.plaf.AbstractSkin;
import cocoa.plaf.FontID;
import cocoa.plaf.WindowSkin;
import cocoa.ui;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.events.MouseEvent;
import flash.system.Capabilities;
import flash.text.engine.TextLine;

import mx.core.IFlexDisplayObject;
import mx.core.ILayoutElement;
import mx.core.IUIComponent;
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

	private static const CONTENT_FRAME_INSETS:Insets = new Insets(0, TITLE_BAR_HEIGHT + 1, 0, BOTTOM_BAR_HEIGHT);
	private static const CONTENT_FRAME_INSETS_TOOLBAR:Insets = new Insets(0, TITLE_BAR_HEIGHT + TOOLBAR_SMALL_HEIGHT + 1, 0, BOTTOM_BAR_HEIGHT);

	private static const CONTENT_LAYOUT_INSETS:Insets = new Insets();

	private var resizeGripper:DisplayObject;
	private var closeButton:PushButton;

	private var border:Border;

	private var labelHelper:LabelHelper;

	private static var mover:WindowMover;
	private static var resizer:WindowResizer;

	public function AbstractWindowSkin()
	{
		labelHelper = new LabelHelper(this);
	}

	protected var _useWindowGap:Boolean;
	public function set useWindowGap(value:Boolean):void
	{
		_useWindowGap = value;
	}

	protected function get contentFrameInsets():Insets
	{
		return _toolbar == null ? CONTENT_FRAME_INSETS : CONTENT_FRAME_INSETS_TOOLBAR;
	}

	protected function get contentLayoutInsets():Insets
	{
		return CONTENT_LAYOUT_INSETS;
	}

	protected function get titleBarHeight():Number
	{
		return TITLE_BAR_HEIGHT;
	}

	protected function get titleY():Number
	{
		return 16;
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

	protected function get mouseDownOnContentViewCanMoveWindow():Boolean
	{
		return false;
	}

	protected final function get insetsWidth():Number
	{
		return contentFrameInsets.width + contentLayoutInsets.width;
	}

	protected final function get insetsHeight():Number
	{
		return contentFrameInsets.height + contentLayoutInsets.height;
	}

	override protected function createChildren():void
	{
		// skip super.createChildren() так там только инжектирование, а за него отвечает DialogManager

		labelHelper.font = getFont(FontID.SYSTEM);

		if (_toolbar == null)
		{
			border = laf.getBorder("Window.border");
		}
		else
		{
			border = laf.getBorder("Window.border.toolbar");
			var toolbarSkin:DisplayObject = DisplayObject(_toolbar.createView(laf));
			toolbarSkin.y = titleBarHeight;
			toolbarSkin.height = TOOLBAR_SMALL_HEIGHT;
			addChild(toolbarSkin);
		}
		addChild(DisplayObject(_contentView));

		if (Window(component).resizable && resizeGripper == null)
		{
			resizeGripper = new resizeGripperClass();
			addDisplayObject(resizeGripper);
		}

		if (Window(component).closable)
		{
			closeButton = new PushButton();
			closeButton.lafSubkey = "TitleBar";
			closeButton.action = Window(component).close;
			var closeButtonSkin:DisplayObject = DisplayObject(closeButton.createView(laf));
			if (Capabilities.os.indexOf("Mac OS") != -1)
			{
				closeButtonSkin.x = 4;
				closeButtonSkin.y = 3;
			}
			addChild(closeButtonSkin);
		}

		addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
	}
	
	private function mouseDownHandler(event:MouseEvent):void
	{
		const targetAsTextLine:TextLine = event.target as TextLine;
		if (event.target != this && (targetAsTextLine == null || (targetAsTextLine.parent != this /* так как window skin (то есть this) должен иметь mouseEnabled равный true */ && targetAsTextLine.parent.mouseEnabled)))
		{
			return;
		}

		if (targetAsTextLine == null)
		{
			var mouseY:Number = event.localY;
			var mouseX:Number = event.localX;
			if (mouseY < 0 || mouseX < 0 || mouseX > width || mouseY > height || /* skip shadow */ (!mouseDownOnContentViewCanMoveWindow && mouseY > contentFrameInsets.top && mouseY < (height - contentFrameInsets.bottom)))
			{
				return;
			}

			if (Window(component).resizable && mouseX >= resizeGripper.x && mouseY >= resizeGripper.y)
			{
				if (resizer == null)
				{
					resizer = new WindowResizer();
				}
				resizer.resize(event, this);

				return;
			}
		}

		if (mover == null)
		{
			mover = new WindowMover();
		}
		mover.move(event, this, titleBarHeight);
	}

	public function childCanSkipMeasurement(element:ILayoutElement):Boolean
	{
		// если у окна установлен фиксированный размер, то content pane устанавливается в размер невзирая на его preferred
		return canSkipMeasurement();
	}

	override protected function measure():void
	{
		const insetsWidth:Number = insetsWidth;
		const insetsHeight:Number = insetsHeight;
		measuredMinWidth = _contentView.minWidth + insetsWidth;
		measuredMinHeight = _contentView.minHeight + insetsHeight;

		measuredWidth = _contentView.getExplicitOrMeasuredWidth() + insetsWidth;
		measuredHeight = _contentView.getExplicitOrMeasuredHeight() + insetsHeight;
	}

	protected function drawTitleBottomBorderLine(g:Graphics, w:Number):void
	{
		// линия отделяющая контент от title/tool bar
		g.lineStyle(1, 0x515151);
		const y:Number = contentFrameInsets.top - 1;
		g.moveTo(0, y);
		g.lineTo(w, y);
	}

	protected function get hasBottomBar():Boolean
	{
		return false;
	}

	override protected function updateDisplayList(w:Number, h:Number):void
	{
		var g:Graphics = graphics;
		g.clear();

		if (_title != null)
		{
			labelHelper.validate();
			labelHelper.moveToCenter(w, titleY);
		}

		border.draw(this, g, w, hasBottomBar ? (h - BOTTOM_BAR_HEIGHT) : h);

		drawTitleBottomBorderLine(g, w);

		if (_toolbar != null)
		{
			_toolbar.skin.setActualSize(w, TOOLBAR_SMALL_HEIGHT);
		}

		_contentView.move(contentFrameInsets.left + contentLayoutInsets.left, contentFrameInsets.top + contentLayoutInsets.top);
		_contentView.setActualSize(w - insetsWidth, h - insetsHeight);

		if (Window(component).resizable)
		{
			resizeGripper.x = w - 11 - 4;
			resizeGripper.y = h - 11 - 4;
		}

		if (Window(component).closable)
		{
			var closeButtonSkin:IUIComponent = closeButton.skin;
			closeButtonSkin.setActualSize(closeButtonSkin.getExplicitOrMeasuredWidth(), closeButtonSkin.getExplicitOrMeasuredHeight());
			if (Capabilities.os.indexOf("Mac OS") == -1)
			{
				closeButtonSkin.x = w - 4 - closeButtonSkin.getExplicitOrMeasuredWidth();
			}
		}
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