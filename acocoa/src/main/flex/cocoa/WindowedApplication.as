package cocoa
{
import flash.desktop.NativeApplication;
import flash.desktop.SystemTrayIcon;
import flash.display.NativeWindow;
import flash.display.NativeWindowDisplayState;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.events.Event;
import flash.events.InvokeEvent;
import flash.events.NativeWindowBoundsEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.controls.FlexNativeMenu;
import mx.core.IWindow;
import mx.core.mx_internal;
import mx.events.AIREvent;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.FlexNativeWindowBoundsEvent;
import mx.managers.DragManager;
import mx.managers.SystemManagerGlobals;

use namespace mx_internal;

[Frame(factoryClass='cocoa.SystemManager')]
public class WindowedApplication extends ApplicationImpl implements IWindow
{
	public function WindowedApplication()
	{
		super();

		addEventListener(FlexEvent.PREINITIALIZE, preinitializeHandler);
		addEventListener(FlexEvent.UPDATE_COMPLETE, updateComplete_handler);
		addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);

		var nativeApplication:NativeApplication = NativeApplication.nativeApplication;
		nativeApplication.addEventListener(Event.ACTIVATE, nativeApplication_activateHandler);
		nativeApplication.addEventListener(Event.DEACTIVATE, nativeApplication_deactivateHandler);
		nativeApplication.addEventListener(Event.NETWORK_CHANGE, dispatchEvent);

		nativeApplication.addEventListener(InvokeEvent.INVOKE, nativeApplication_invokeHandler);
		initialInvokes = new Array();

		//Force DragManager to instantiate so that it can handle drags from
		//outside the app.
		//noinspection BadExpressionStatementJS
		DragManager.isDragging;
	}

	private var _nativeWindow:NativeWindow;

	/**
	 *  @private
	 */
	private var _nativeWindowVisible:Boolean = true;

	/**
	 *  @private
	 */
	private var toMax:Boolean = false;

	/**
	 *  @private
	 */
	private var initialInvokes:Array;

	/**
	 *  @private
	 */
	private var invokesPending:Boolean = true;

	/**
	 *  @private
	 */
	private var oldX:Number;

	/**
	 *  @private
	 */
	private var oldY:Number;

	/**
	 *  @private
	 */
	private var windowBoundsChanged:Boolean = true;

	/**
	 *  @private
	 */
	private var prevActiveFrameRate:Number = -1;

	/**
	 *  @private
	 *  Determines whether the WindowedApplication opens in an active state.
	 *  If you are opening up other windows at startup that should be active,
	 *  this will ensure that the WindowedApplication does not steal focus.
	 *
	 *  @default true
	 */
	private var activateOnOpen:Boolean = true;

	/**
	 *  @private
	 */
	private var ucCount:Number = 0;


	[Bindable("heightChanged")]
	[Inspectable(category="General")]
	[PercentProxy("percentHeight")]

	/**
	 *  @private
	 */
	override public function get height():Number
	{
		return _bounds.height;
	}

	/**
	 *  @private
	 *  Also sets the stage's height.
	 */
	override public function set height(value:Number):void
	{
		if (value < minHeight)
			value = minHeight;
		else if (value > maxHeight)
			value = maxHeight;

		_bounds.height = value;
		boundsChanged = true;

		invalidateProperties();
		invalidateSize();

		// the heightChanged event is dispatched in commitProperties instead of
		// here because it can change based on user-interaction with the window
		// size and _height is set in there so don't want to prematurely
		// dispatch here yet
	}

	//----------------------------------
	//  maxHeight
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the maxHeight property.
	 */
	private var _maxHeight:Number = 2880;

	/**
	 *  @private
	 *  Keeps track of whether maxHeight property changed so we can
	 *  handle it in commitProperties.
	 */
	private var maxHeightChanged:Boolean = false;

	[Bindable("maxHeightChanged")]
	[Bindable("windowComplete")]

	/**
	 *  @private
	 */
	override public function get maxHeight():Number
	{
		if (nativeWindow && !maxHeightChanged)
			return nativeWindow.maxSize.y - chromeHeight();
		else
			return _maxHeight;
	}

	/**
	 *  @private
	 *  Specifies the maximum height of the application's window.
	 *
	 *  @default dependent on the operating system and the AIR systemChrome setting.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	override public function set maxHeight(value:Number):void
	{
		_maxHeight = value;
		maxHeightChanged = true;
		invalidateProperties();
	}

	//----------------------------------
	//  maxWidth
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the maxWidth property.
	 */
	private var _maxWidth:Number = 2880;

	/**
	 *  @private
	 *  Keeps track of whether maxWidth property changed so we can
	 *  handle it in commitProperties.
	 */
	private var maxWidthChanged:Boolean = false;

	[Bindable("maxWidthChanged")]
	[Bindable("windowComplete")]

	/**
	 *  @private
	 */
	override public function get maxWidth():Number
	{
		if (nativeWindow && !maxWidthChanged)
			return nativeWindow.maxSize.x - chromeWidth();
		else
			return _maxWidth;
	}

	/**
	 *  @private
	 *  Specifies the maximum width of the application's window.
	 *
	 *  @default dependent on the operating system and the AIR systemChrome setting.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	override public function set maxWidth(value:Number):void
	{
		_maxWidth = value;
		maxWidthChanged = true;
		invalidateProperties();
	}

	//---------------------------------
	//  minHeight
	//---------------------------------

	/**
	 *  @private
	 */
	private var _minHeight:Number = 0;

	/**
	 *  @private
	 *  Keeps track of whether minHeight property changed so we can
	 *  handle it in commitProperties.
	 */
	private var minHeightChanged:Boolean = false;

	[Bindable("minHeightChanged")]
	[Bindable("windowComplete")]

	/**
	 *  @private
	 *  Specifies the minimum height of the application's window.
	 *
	 *  @default dependent on the operating system and the AIR systemChrome setting.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	override public function get minHeight():Number
	{
		if (nativeWindow && !minHeightChanged)
			return nativeWindow.minSize.y - chromeHeight();
		else
			return _minHeight;
	}

	/**
	 *  @private
	 */
	override public function set minHeight(value:Number):void
	{
		_minHeight = value;
		minHeightChanged = true;
		invalidateProperties();
	}

	//---------------------------------
	//  minWidth
	//---------------------------------

	/**
	 *  @private
	 *  Storage for the minWidth property.
	 */
	private var _minWidth:Number = 0;

	/**
	 *  @private
	 *  Keeps track of whether minWidth property changed so we can
	 *  handle it in commitProperties.
	 */
	private var minWidthChanged:Boolean = false;

	[Bindable("minWidthChanged")]
	[Bindable("windowComplete")]

	/**
	 *  @private
	 *  Specifies the minimum width of the application's window.
	 *
	 *  @default dependent on the operating system and the AIR systemChrome setting.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	override public function get minWidth():Number
	{
		if (nativeWindow && !minWidthChanged)
			return nativeWindow.minSize.x - chromeWidth();
		else
			return _minWidth;
	}

	/**
	 *  @private
	 */
	override public function set minWidth(value:Number):void
	{
		_minWidth = value;
		minWidthChanged = true;
		invalidateProperties();
	}

	//----------------------------------
	//  visible
	//----------------------------------

	[Bindable("hide")]
	[Bindable("show")]
	[Bindable("windowComplete")]

	/**
	 *  @private
	 *  Also sets the NativeWindow's visibility.
	 */
	override public function get visible():Boolean
	{
		if (nativeWindow && nativeWindow.closed)
			return false;
		if (nativeWindow)
			return nativeWindow.visible;
		else
			return _nativeWindowVisible;
	}

	/**
	 *  @private
	 */
	override public function set visible(value:Boolean):void
	{
		setVisible(value);
	}

	/**
	 *  @private
	 *  We override setVisible because there's the flash display object concept
	 *  of visibility and also the nativeWindow concept of visibility.
	 */
	override public function setVisible(value:Boolean,
										noEvent:Boolean = false):void
	{
		// first handle the native window stuff
		if (!_nativeWindow)
		{
			_nativeWindowVisible = value;
			invalidateProperties();
		}
		else if (!_nativeWindow.closed)
		{
			if (value)
			{
				_nativeWindow.visible = value;
			}
			else
			{
				// in the conditions below we will play an effect
//				if (getStyle("hideEffect") && initialized && $visible != value)
//					addEventListener(EffectEvent.EFFECT_END, hideEffectEndHandler);
//				else
					_nativeWindow.visible = value;
			}
		}

		// now call super.setVisible
		super.setVisible(value, noEvent);
	}

	//----------------------------------
	//  width
	//----------------------------------

	[Bindable("widthChanged")]
	[Inspectable(category="General")]
	[PercentProxy("percentWidth")]

	/**
	 *  @private
	 */
	override public function get width():Number
	{
		return _bounds.width;
	}

	/**
	 *  @private
	 *  Also sets the stage's width.
	 */
	override public function set width(value:Number):void
	{
		if (value < minWidth)
			value = minWidth;
		else if (value > maxWidth)
			value = maxWidth;

		_bounds.width = value;
		boundsChanged = true;

		invalidateProperties();
		invalidateSize();

		// the widthChanged event is dispatched in commitProperties instead of
		// here because it can change based on user-interaction with the window
		// size and _width is set in there so don't want to prematurely
		// dispatch here yet
	}

	//----------------------------------
	//  alwaysInFront
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the alwaysInFront property.
	 */
	private var _alwaysInFront:Boolean = false;

	/**
	 *  Determines whether the underlying NativeWindow is always in front of other windows.
	 *
	 *  @default false
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get alwaysInFront():Boolean
	{
		if (_nativeWindow && !_nativeWindow.closed)
			return nativeWindow.alwaysInFront;
		else
			return _alwaysInFront;
	}

	/**
	 *  @private
	 */
	public function set alwaysInFront(value:Boolean):void
	{
		_alwaysInFront = value;
		if (_nativeWindow && !_nativeWindow.closed)
			nativeWindow.alwaysInFront = value;
	}

	//----------------------------------
	//  backgroundFrameRate
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the backgroundFrameRate property.
	 */
	private var _backgroundFrameRate:Number = -1;

	/**
	 *  Specifies the frame rate to use when the application is inactive.
	 *  When set to -1, no background frame rate throttling occurs.
	 *
	 *  @default -1
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get backgroundFrameRate():Number
	{
		return _backgroundFrameRate;
	}

	/**
	 *  @private
	 */
	public function set backgroundFrameRate(frameRate:Number):void
	{
		_backgroundFrameRate = frameRate;
	}

	//----------------------------------
	//  bounds
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the bounds property.
	 */
	private var _bounds:Rectangle = new Rectangle(0, 0, 0, 0);

	/**
	 *  @private
	 */
	private var boundsChanged:Boolean = false;

	/**
	 *  @private
	 *  Storage for the height and width
	 */
	protected function get bounds():Rectangle
	{
		return nativeWindow.bounds;
	}

	/**
	 *  @private
	 */
	protected function set bounds(value:Rectangle):void
	{
		nativeWindow.bounds = value;
		boundsChanged = true;

		invalidateProperties();
		invalidateSize();
	}

	//----------------------------------
	//  maximizable
	//----------------------------------

	/**
	 *  Specifies whether the window can be maximized.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get maximizable():Boolean
	{
		if (!nativeWindow.closed)
			return nativeWindow.maximizable;
		else
			return false;
	}

	//----------------------------------
	//  minimizable
	//----------------------------------

	/**
	 *  Specifies whether the window can be minimized.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get minimizable():Boolean
	{
		if (!nativeWindow.closed)
			return nativeWindow.minimizable;
		else
			return false;
	}

	//----------------------------------
	//  menu
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the menu property.
	 */
	private var _menu:FlexNativeMenu;

	/**
	 *  @private
	 */
	private var menuChanged:Boolean = false;

	/**
	 *  The application menu for operating systems that support an application menu,
	 *  or the window menu of the application's initial window for operating
	 *  systems that support window menus.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get menu():FlexNativeMenu
	{
		return _menu;
	}

	/**
	 *  @private
	 */
	public function set menu(value:FlexNativeMenu):void
	{
		if (_menu)
		{
			_menu.automationParent = null;
			_menu.automationOwner = null;
		}

		_menu = value;
		menuChanged = true;

		if (_menu)
		{
			menu.automationParent = this;
			menu.automationOwner = this;
		}
	}

	//----------------------------------
	//  nativeWindow
	//----------------------------------

	/**
	 *  The NativeWindow used by this WindowedApplication component (the initial
	 *  native window of the application).
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get nativeWindow():NativeWindow
	{
		if ((systemManager != null) && (systemManager.stage != null))
			return systemManager.stage.nativeWindow;

		return null;
	}

	//---------------------------------
	//  resizable
	//---------------------------------

	/**
	 *  Specifies whether the window can be resized.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get resizable():Boolean
	{
		if (nativeWindow.closed)
			return false;
		return nativeWindow.resizable;
	}


	//----------------------------------
	//  nativeApplication
	//----------------------------------

	/**
	 *  The NativeApplication object representing the AIR application.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get nativeApplication():NativeApplication
	{
		return NativeApplication.nativeApplication;
	}

	//---------------------------------
	//  showStatusBar
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the showStatusBar property.
	 */
	private var _showStatusBar:Boolean = true;

	/**
	 *  @private
	 */
	private var showStatusBarChanged:Boolean = true;

	/**
	 *  If <code>true</code>, the status bar is visible.
	 *
	 *  <p>The status bar only appears when you use the WindowedApplicationSkin
	 *  class or the SparkChromeWindowedApplicationSkin class as the skin for
	 *  your application or any of your application's windows.</p>
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get showStatusBar():Boolean
	{
		return _showStatusBar;
	}

	/**
	 *  @private
	 */
	public function set showStatusBar(value:Boolean):void
	{
		if (_showStatusBar == value)
			return;

		_showStatusBar = value;
		showStatusBarChanged = true;

		invalidateProperties();
		invalidateDisplayList();
	}

	//----------------------------------
	//  status
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the status property.
	 */
	private var _status:String = "";

	/**
	 *  @private
	 */
	private var statusChanged:Boolean = false;

	[Bindable("statusChanged")]

	/**
	 *  The string that appears in the status bar, if it is visible.
	 *
	 *  @default ""
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get status():String
	{
		return _status;
	}

	/**
	 *  @private
	 */
	public function set status(value:String):void
	{
		_status = value;
		statusChanged = true;

		invalidateProperties();
		invalidateSize();

		dispatchEvent(new Event("statusChanged"));
	}

	//----------------------------------
	//  systemChrome
	//----------------------------------

	private var _systemChrome:String = NativeWindowSystemChrome.STANDARD;

	/**
	 *  Specifies the type of system chrome (if any) the window has.
	 *  The set of possible values is defined by the constants
	 *  in the NativeWindowSystemChrome class.
	 *
	 *  @see flash.display.NativeWindow#systemChrome
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get systemChrome():String
	{
		return _systemChrome;
	}

	//----------------------------------
	//  systemTrayIconMenu
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the systemTrayIconMenu property.
	 */
	private var _systemTrayIconMenu:FlexNativeMenu;

	/**
	 *  The system tray icon menu. Some operating systems do not support system tray icon menus.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get systemTrayIconMenu():FlexNativeMenu
	{
		return _systemTrayIconMenu;
	}

	/**
	 *  @private
	 */
	public function set systemTrayIconMenu(value:FlexNativeMenu):void
	{
		_systemTrayIconMenu = value;

		if (NativeApplication.supportsSystemTrayIcon)
		{
			if (nativeApplication.icon is SystemTrayIcon)
				SystemTrayIcon(nativeApplication.icon).menu = value.nativeMenu;
		}
	}

	//----------------------------------
	//  title
	//----------------------------------

	/**
	 *  @private
	 *  Storage for the title property.
	 */
	private var _title:String = "";

	/**
	 *  @private
	 */
	private var titleChanged:Boolean = false;

	[Bindable("titleChanged")]

	/**
	 *  The title that appears in the window title bar and
	 *  the taskbar.
	 *
	 *  If you are using system chrome and you set this property to something
	 *  different than the &lt;title&gt; tag in your application.xml,
	 *  you may see the title from the XML file appear briefly first.
	 *
	 *  @default ""
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get title():String
	{
		return _title;
	}

	/**
	 *  @private
	 */
	public function set title(value:String):void
	{
		_title = value;
		titleChanged = true;

		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();

		dispatchEvent(new Event("titleChanged"));
	}

	//----------------------------------
	//  titleIcon
	//----------------------------------

	/**
	 *  @private
	 *  A reference to this container's title icon.
	 */
	private var _titleIcon:Class;

	/**
	 *  @private
	 */
	private var titleIconChanged:Boolean = false;

	[Bindable("titleIconChanged")]

	/**
	 *  The Class (usually an image) used to draw the title bar icon.
	 *
	 *  @default null
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get titleIcon():Class
	{
		return _titleIcon;
	}

	/**
	 *  @private
	 */
	public function set titleIcon(value:Class):void
	{
		_titleIcon = value;
		titleIconChanged = true;

		invalidateProperties();
		invalidateSize();
		invalidateDisplayList();

		dispatchEvent(new Event("titleIconChanged"));
	}

	//----------------------------------
	//  transparent
	//----------------------------------

	/**
	 *  Specifies whether the window is transparent.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get transparent():Boolean
	{
		if (nativeWindow.closed)
			return false;
		return nativeWindow.transparent;
	}

	//----------------------------------
	//  type
	//----------------------------------

	/**
	 *  Specifies the type of NativeWindow that this component
	 *  represents. The set of possible values is defined by the constants
	 *  in the NativeWindowType class.
	 *
	 *  @see flash.display.NativeWindowType
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function get type():String
	{
		// The initial window is always of type "normal".
		return NativeWindowType.NORMAL;
	}


	//----------------------------------
	//  useNativeDragManager
	//----------------------------------

	[Inspectable(defaultValue="true")]

	/**
	 *  If <code>true</code>, the DragManager should use the NativeDragManagerImpl implementation class.
	 *  If <code>false</code>, then the DragManagerImpl class will be used.
	 *
	 *  <p>Note: This property cannot be set by ActionScript code; it must be set in MXML code.
	 *  That means you cannot change its value at run time.</p>
	 *
	 *  <p>By default, the DragManager  for AIR applications built in Flex uses the
	 *  NativeDragManagerImpl class as the implementation class.
	 *  Flash Player applications build in Flex use the DragManagerImpl class. </p>
	 *
	 *  <p>The NativeDragManagerImpl class is a bridge between the AIR NativeDragManager API
	 *  and the Flex DragManager API.
	 *  The AIR NativeDragManager class uses the operating system's drag and drop APIs.
	 *  It supports dragging between AIR windows and between the operating system and AIR.
	 *  Because the operating system controls the drag-and-drop operation,
	 *  it is not possible to customize the cursors during a drag.
	 *  Also, you have no control over the drop animation.
	 *  The behavior is dependent upon the operating system and has some inconsistencies across different platforms.</p>
	 *
	 *  <p>The DragManagerImpl class does not use the operating system for drag-and-drop.
	 *  Instead, it controls the entire drag-and-drop process.
	 *  It supports customizing the cursors and provides a drop animation.
	 *  However, it does not allow dragging between AIR windows and between the operating system or AIR window.</p>
	 *
	 *  @default true
	 *
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */

	/*  This property is not directly read by the systemManager. It is here so that it gets
	 *  picked up by the compiler and included in the info() structure
	 *  for the generated system manager.  */
	public var useNativeDragManager:Boolean = true;

	//--------------------------------------------------------------------------
	//
	//  Overridden methods: UIComponent
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	override protected function commitProperties():void
	{
		super.commitProperties();

		// AIR won't allow you to set the min width greater than the current
		// max width (same is true for height). You also can't set the max
		// width less than the current min width (same is true for height).
		// This makes the updating of the new minSize and maxSize a bit tricky.
		if (minWidthChanged || minHeightChanged || maxWidthChanged || maxHeightChanged)
		{
			var minSize:Point = nativeWindow.minSize;
			var maxSize:Point = nativeWindow.maxSize;
			var newMinWidth:Number = minWidthChanged ? _minWidth + chromeWidth() : minSize.x;
			var newMinHeight:Number = minHeightChanged ? _minHeight + chromeHeight() : minSize.y;
			var newMaxWidth:Number = maxWidthChanged ? _maxWidth + chromeWidth() : maxSize.x;
			var newMaxHeight:Number = maxHeightChanged ? _maxHeight + chromeHeight() : maxSize.y;

			if (minWidthChanged || minHeightChanged)
			{
				// If the new min size is greater than the old max size, then
				// we need to set the new max size now.
				if ((maxWidthChanged && newMinWidth > minSize.x) ||
					(maxHeightChanged && newMinHeight > minSize.y))
				{
					nativeWindow.maxSize = new Point(newMaxWidth, newMaxHeight);
				}

				nativeWindow.minSize = new Point(newMinWidth, newMinHeight);
			}

			// Set the max width or height if it is not already set. The max
			// width and height could have been set above when setting minSize
			// but the max size would have been rejected by AIR if it were less
			// than the old min size.
			if (newMaxWidth != maxSize.x || newMaxHeight != maxSize.y)
				nativeWindow.maxSize = new Point(newMaxWidth, newMaxHeight);
		}

		// minimum width and height
		if (minWidthChanged || minHeightChanged)
		{
			if (minWidthChanged)
			{
				minWidthChanged = false;
				if (width < minWidth)
					width = minWidth;
				dispatchEvent(new Event("minWidthChanged"));
			}
			if (minHeightChanged)
			{
				minHeightChanged = false;
				if (height < minHeight)
					height = minHeight;
				dispatchEvent(new Event("minHeightChanged"));
			}
		}

		// maximum width and height
		if (maxWidthChanged || maxHeightChanged)
		{
			windowBoundsChanged = true;

			if (maxWidthChanged)
			{
				maxWidthChanged = false;
				if (width > maxWidth)
					width = maxWidth;
				dispatchEvent(new Event("maxWidthChanged"));
			}
			if (maxHeightChanged)
			{
				maxHeightChanged = false;
				if (height > maxHeight)
					height = maxHeight;
				dispatchEvent(new Event("maxHeightChanged"));
			}

		}

		if (boundsChanged)
		{
			// Work around an AIR issue setting the stageHeight to zero when
			// using system chrome. The set of the stage.stageHeight property
			// is rejected unless the nativeWindow is first set to the proper
			// height.
			// Don't perform this workaround if the window has zero height due
			// to being minimized. Setting the nativeWindow height to non-zero
			// causes AIR to restore the window.
			if (_bounds.height == 0 &&
				nativeWindow.displayState != NativeWindowDisplayState.MINIMIZED &&
				systemChrome == NativeWindowSystemChrome.STANDARD)
				nativeWindow.height = chromeHeight() + _bounds.height;

			systemManager.stage.stageWidth = _width = _bounds.width;
			systemManager.stage.stageHeight = _height = _bounds.height;

			boundsChanged = false;

			// don't know whether height or width changed
			dispatchEvent(new Event("widthChanged"));
			dispatchEvent(new Event("heightChanged"));
		}

		if (windowBoundsChanged)
		{
			_bounds.width = _width = systemManager.stage.stageWidth;
			_bounds.height = _height = systemManager.stage.stageHeight;
			windowBoundsChanged = false;

			// don't know whether height or width changed
			dispatchEvent(new Event("widthChanged"));
			dispatchEvent(new Event("heightChanged"));
		}

		if (menuChanged && !nativeWindow.closed)
		{
			menuChanged = false;

			if (menu == null)
			{
				if (NativeApplication.supportsMenu)
					nativeApplication.menu = null;
				else if (NativeWindow.supportsMenu)
					nativeWindow.menu = null;
			}
			else if (menu.nativeMenu)
			{
				if (NativeApplication.supportsMenu)
					nativeApplication.menu = menu.nativeMenu;
				else if (NativeWindow.supportsMenu)
					nativeWindow.menu = menu.nativeMenu;
			}

			dispatchEvent(new Event("menuChanged"));
		}

		if (toMax)
		{
			toMax = false;
			if (!nativeWindow.closed)
				nativeWindow.maximize();
		}
	}

	/**
	 *  @private
	 */
	override public function initialize():void
	{
		// initialize _nativeWindow as soon as possible and
		// get the value of systemChrome.
		_nativeWindow = systemManager.stage.nativeWindow;
		_systemChrome = _nativeWindow.systemChrome;

		super.initialize();
	}

	/**
	 *  @private
	 */
	override public function move(x:Number, y:Number):void
	{
		if (nativeWindow && !nativeWindow.closed)
		{
			var tmp:Rectangle = nativeWindow.bounds;
			tmp.x = x;
			tmp.y = y;
			nativeWindow.bounds = tmp;
		}
	}

	/**
	 *  Activates the underlying NativeWindow (even if this application is not the active one).
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function activate():void
	{
		if (!systemManager.stage.nativeWindow.closed)
			systemManager.stage.nativeWindow.activate();
	}

	/**
	 *  Closes the application's NativeWindow (the initial native window opened by the application). This action is cancelable.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function close():void
	{
		if (!nativeWindow.closed)
		{
			var e:Event = new Event("closing", true, true);
			stage.nativeWindow.dispatchEvent(e);
			if (!e.isDefaultPrevented())
				stage.nativeWindow.close();
		}
	}

	/**
	 *  Closes the window and exits the application.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function exit():void
	{
		nativeApplication.exit();
	}

	/**
	 *  Maximizes the window, or does nothing if it's already maximized.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function maximize():void
	{

		if (!nativeWindow || !nativeWindow.maximizable || nativeWindow.closed)
			return;
		if (systemManager.stage.nativeWindow.displayState != NativeWindowDisplayState.MAXIMIZED)
		{
			var f:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(
					NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
					false, true, systemManager.stage.nativeWindow.displayState,
					NativeWindowDisplayState.MAXIMIZED);
			systemManager.stage.nativeWindow.dispatchEvent(f);
			if (!f.isDefaultPrevented())
			{
				toMax = true;
				invalidateProperties();
			}
		}
	}

	/**
	 *  Minimizes the window.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function minimize():void
	{
		if (!minimizable)
			return;

		if (!nativeWindow.closed)
		{
			var e:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(
					NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
					false, true, nativeWindow.displayState,
					NativeWindowDisplayState.MINIMIZED);
			stage.nativeWindow.dispatchEvent(e);
			if (!e.isDefaultPrevented())
				stage.nativeWindow.minimize();
		}
	}

	/**
	 *  Restores the window (unmaximizes it if it's maximized, or
	 *  unminimizes it if it's minimized).
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function restore():void
	{
		if (!nativeWindow.closed)
		{
			var e:NativeWindowDisplayStateEvent;
			if (stage.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED)
			{
				e = new NativeWindowDisplayStateEvent(
						NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
						false, true, NativeWindowDisplayState.MAXIMIZED,
						NativeWindowDisplayState.NORMAL);
				stage.nativeWindow.dispatchEvent(e);
				if (!e.isDefaultPrevented())
					nativeWindow.restore();
			}
			else if (stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED)
			{
				e = new NativeWindowDisplayStateEvent(
						NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
						false, true, NativeWindowDisplayState.MINIMIZED,
						NativeWindowDisplayState.NORMAL);
				stage.nativeWindow.dispatchEvent(e);
				if (!e.isDefaultPrevented())
					nativeWindow.restore();
			}
		}
	}

	/**
	 *  Orders the window just behind another. To order the window behind
	 *  a NativeWindow that does not implement IWindow, use this window's
	 *  NativeWindow's <code>orderInBackOf()</code> method.
	 *
	 *  @param window The IWindow (Window or WindowedAplication)
	 *  to order this window behind.
	 *
	 *  @return <code>true</code> if the window was successfully sent behind;
	 *  <code>false</code> if the window is invisible or minimized.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function orderInBackOf(window:IWindow):Boolean
	{
		if (nativeWindow && !nativeWindow.closed)
			return nativeWindow.orderInBackOf(window.nativeWindow);
		else
			return false;
	}

	/**
	 *  Orders the window just in front of another. To order the window
	 *  in front of a NativeWindow that does not implement IWindow, use this
	 *  window's NativeWindow's <code>orderInFrontOf()</code> method.
	 *
	 *  @param window The IWindow (Window or WindowedAplication)
	 *  to order this window in front of.
	 *
	 *  @return <code>true</code> if the window was successfully sent in front;
	 *  <code>false</code> if the window is invisible or minimized.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function orderInFrontOf(window:IWindow):Boolean
	{
		if (nativeWindow && !nativeWindow.closed)
			return nativeWindow.orderInFrontOf(window.nativeWindow);
		else
			return false;
	}

	/**
	 *  Orders the window behind all others in the same application.
	 *
	 *  @return <code>true</code> if the window was successfully sent to the back;
	 *  <code>false</code> if the window is invisible or minimized.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function orderToBack():Boolean
	{
		if (nativeWindow && !nativeWindow.closed)
			return nativeWindow.orderToBack();
		else
			return false;
	}

	/**
	 *  Orders the window in front of all others in the same application.
	 *
	 *  @return <code>true</code> if the window was successfully sent to the front;
	 *  <code>false</code> if the window is invisible or minimized.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	public function orderToFront():Boolean
	{
		if (nativeWindow && !nativeWindow.closed)
			return nativeWindow.orderToFront();
		else
			return false;
	}


	/**
	 *  @private
	 *  Returns the width of the chrome for the window
	 */
	private function chromeWidth():Number
	{
		return nativeWindow.width - systemManager.stage.stageWidth;
	}

	/**
	 *  @private
	 *  Returns the height of the chrome for the window
	 */
	private function chromeHeight():Number
	{
		return nativeWindow.height - systemManager.stage.stageHeight;
	}

	/**
	 *  @private
	 *  Starts a system resize.
	 */
	protected function startResize(start:String):void
	{
		if (!nativeWindow.closed)
			if (nativeWindow.resizable)
				stage.nativeWindow.startResize(start);
	}

	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private function creationCompleteHandler(event:Event):void
	{
		addEventListener(Event.ENTER_FRAME, enterFrameHandler);
	}

	/**
	 *  @private
	 */
	private function enterFrameHandler(e:Event):void
	{
		removeEventListener(Event.ENTER_FRAME, enterFrameHandler);

		// If nativeApplication.nativeApplication.exit() has been called,
		// the window will already be closed.
		if (stage.nativeWindow.closed)
			return;

		//window properties that have been stored till window exists
		//now get applied to window
		stage.nativeWindow.visible = _nativeWindowVisible;
		dispatchEvent(new AIREvent(AIREvent.WINDOW_COMPLETE));

		// Now let any invoke events received from nativeApplication
		// during initialization, flow to our listeners.
		dispatchPendingInvokes();

		if (_nativeWindowVisible && activateOnOpen)
			stage.nativeWindow.activate();
		stage.nativeWindow.alwaysInFront = _alwaysInFront;
	}

	/**
	 *  @private
	 */
	private function dispatchPendingInvokes():void
	{
		invokesPending = false;
		for each (var event:InvokeEvent in initialInvokes)
			dispatchEvent(event);
		initialInvokes = null;
	}

	/**
	 *  @private
	 */
	private function hideEffectEndHandler(event:Event):void
	{
		if (!_nativeWindow.closed)
			_nativeWindow.visible = false;
		removeEventListener(EffectEvent.EFFECT_END, hideEffectEndHandler);
	}

	/**
	 *  @private
	 */
	private function windowMinimizeHandler(event:Event):void
	{
		if (!nativeWindow.closed)
			stage.nativeWindow.minimize();
		removeEventListener(EffectEvent.EFFECT_END, windowMinimizeHandler);
	}

	/**
	 *  @private
	 */
	private function windowUnminimizeHandler(event:Event):void
	{
		removeEventListener(EffectEvent.EFFECT_END, windowUnminimizeHandler);
	}

	/**
	 *  @private
	 */
	private function window_moveHandler(event:NativeWindowBoundsEvent):void
	{
		dispatchEvent(new FlexNativeWindowBoundsEvent(FlexNativeWindowBoundsEvent.WINDOW_MOVE, event.bubbles, event.cancelable,
				event.beforeBounds, event.afterBounds));
	}

	/**
	 *  @private
	 */
	private function window_displayStateChangeHandler(
			event:NativeWindowDisplayStateEvent):void
	{
		// Redispatch event.
		dispatchEvent(event);
		height = systemManager.stage.stageHeight;
		width = systemManager.stage.stageWidth;

		// Restored from a minimized state.
		if (event.beforeDisplayState == NativeWindowDisplayState.MINIMIZED)
		{
			addEventListener(EffectEvent.EFFECT_END, windowUnminimizeHandler);
			dispatchEvent(new Event("windowUnminimize"));
		}

		// If we have been maximized or restored then invalidate so we can
		// resize.
		if (event.afterDisplayState == NativeWindowDisplayState.MAXIMIZED ||
			event.afterDisplayState == NativeWindowDisplayState.NORMAL)
		{
			invalidateSize();
			invalidateDisplayList();
		}

	}

	/**
	 *  @private
	 */
	private function window_displayStateChangingHandler(
			event:NativeWindowDisplayStateEvent):void
	{
		//redispatch event for cancellation purposes
		dispatchEvent(event);
		if (event.isDefaultPrevented())
			return;
		if (event.afterDisplayState == NativeWindowDisplayState.MINIMIZED)
		{
//			if (getStyle("minimizeEffect"))
//			{
//				event.preventDefault();
//				addEventListener(EffectEvent.EFFECT_END, windowMinimizeHandler);
//				dispatchEvent(new Event("windowMinimize"));
//			}
		}

	}

	/**
	 *  @private
	 */
	private function preinitializeHandler(event:Event = null):void
	{
		systemManager.stage.nativeWindow.addEventListener(
				NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING,
				window_displayStateChangingHandler);
		systemManager.stage.nativeWindow.addEventListener(
				NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE,
				window_displayStateChangeHandler);
		systemManager.stage.nativeWindow.addEventListener(
				"closing", window_closingHandler);
		systemManager.stage.nativeWindow.addEventListener(
				"close", window_closeHandler, false, 0, true);

		// For the edge case, e.g. visible is set to true in
		// AIR xml file, we fabricate an activate event, since Flex
		// comes in late to the show.
		if (systemManager.stage.nativeWindow.active)
			dispatchEvent(new AIREvent(AIREvent.WINDOW_ACTIVATE));

		systemManager.stage.nativeWindow.addEventListener(
				"activate", nativeWindow_activateHandler, false, 0, true);
		systemManager.stage.nativeWindow.addEventListener(
				"deactivate", nativeWindow_deactivateHandler, false, 0, true);

		systemManager.stage.nativeWindow.addEventListener(
				NativeWindowBoundsEvent.MOVING, window_boundsHandler);

		systemManager.stage.nativeWindow.addEventListener(
				NativeWindowBoundsEvent.MOVE, window_moveHandler);

		systemManager.stage.nativeWindow.addEventListener(
				NativeWindowBoundsEvent.RESIZING, window_boundsHandler);

		systemManager.stage.nativeWindow.addEventListener(
				NativeWindowBoundsEvent.RESIZE, window_resizeHandler);

	}

	/**
	 *  @private
	 */
	private function window_boundsHandler(event:NativeWindowBoundsEvent):void
	{

		var newBounds:Rectangle = event.afterBounds;
		if (event.type == NativeWindowBoundsEvent.MOVING)
		{
			dispatchEvent(event);
			if (event.isDefaultPrevented())
				return;
		}
		else //event is resizing
		{
			dispatchEvent(event);
			if (event.isDefaultPrevented())
				return;
			var cancel:Boolean = false;
			if (newBounds.width < nativeWindow.minSize.x)
			{
				cancel = true;
				if (newBounds.x != event.beforeBounds.x && !isNaN(oldX))
					newBounds.x = oldX;
				newBounds.width = nativeWindow.minSize.x;
			}
			else if (newBounds.width > nativeWindow.maxSize.x)
			{
				cancel = true;
				if (newBounds.x != event.beforeBounds.x && !isNaN(oldX))
					newBounds.x = oldX;
				newBounds.width = nativeWindow.maxSize.x;
			}
			if (newBounds.height < nativeWindow.minSize.y)
			{
				cancel = true;
				if (event.afterBounds.y != event.beforeBounds.y && !isNaN(oldY))
					newBounds.y = oldY;
				newBounds.height = nativeWindow.minSize.y;
			}
			else if (newBounds.height > nativeWindow.maxSize.y)
			{
				cancel = true;
				if (event.afterBounds.y != event.beforeBounds.y && !isNaN(oldY))
					newBounds.y = oldY;
				newBounds.height = nativeWindow.maxSize.y;
			}
			if (cancel)
			{
				event.preventDefault();
				stage.nativeWindow.bounds = newBounds;
				windowBoundsChanged = true;
				invalidateProperties();
			}
		}
		oldX = newBounds.x;
		oldY = newBounds.y;
	}

	/**
	 *  @private
	 */
	private function window_closeEffectEndHandler(event:Event):void
	{
		removeEventListener(EffectEvent.EFFECT_END, window_closeEffectEndHandler);
		if (!nativeWindow.closed)
			stage.nativeWindow.close();
	}

	/**
	 *  @private
	 */
	private function window_closingHandler(event:Event):void
	{
		var e:Event = new Event("closing", true, true);
		dispatchEvent(e);
		if (e.isDefaultPrevented())
		{
			event.preventDefault();
		}
//		else if (getStyle("closeEffect") &&
//				 stage.nativeWindow.transparent)
//		{
//			addEventListener(EffectEvent.EFFECT_END, window_closeEffectEndHandler);
//			dispatchEvent(new Event("windowClose"));
//			event.preventDefault();
//		}
	}

	/**
	 *  @private
	 */
	private function window_closeHandler(event:Event):void
	{
		dispatchEvent(new Event("close"));
	}

	/**
	 *  @private
	 */
	private function window_resizeHandler(event:NativeWindowBoundsEvent):void
	{
		// Only validateNow if we don't already have a window bounds
		// update pending. Otherwise, we'll miss a chance to layout with
		// the modified bounds.  ** We really should revisit why we call
		// validateNow here to begin with **.
		if (!windowBoundsChanged)
		{
			windowBoundsChanged = true;
			invalidateProperties();
			invalidateDisplayList();
			validateNow();
		}

		var e:FlexNativeWindowBoundsEvent =
				new FlexNativeWindowBoundsEvent(FlexNativeWindowBoundsEvent.WINDOW_RESIZE, event.bubbles, event.cancelable,
						event.beforeBounds, event.afterBounds);
		dispatchEvent(e);
	}

	/**
	 *  @private
	 */
	private function nativeApplication_activateHandler(event:Event):void
	{
		dispatchEvent(new AIREvent(AIREvent.APPLICATION_ACTIVATE));

		// Only the initial WindowedApplication instance manages background framerate.
		var isPrimaryApplication:Boolean =
				SystemManagerGlobals.topLevelSystemManagers[0] == systemManager;

		// Restore throttled framerate if appropriate when application is activated.
		if (prevActiveFrameRate >= 0 && stage && isPrimaryApplication)
		{
			stage.frameRate = prevActiveFrameRate;
			prevActiveFrameRate = -1;
		}
	}

	/**
	 *  @private
	 */
	private function nativeApplication_deactivateHandler(event:Event):void
	{
		dispatchEvent(new AIREvent(AIREvent.APPLICATION_DEACTIVATE));

		// Only the initial WindowedApplication instance manages background framerate.
		var isPrimaryApplication:Boolean =
				SystemManagerGlobals.topLevelSystemManagers[0] == systemManager;

		// Throttle framerate if appropriate when application is deactivated.
		// Ensure we've received an updateComplete on the chance our layout
		// manager is using phased instantiation (we don't wish to store a
		// maxed out (1000fps) framerate).
		if ((_backgroundFrameRate >= 0) && (ucCount > 0) && stage && isPrimaryApplication)
		{
			prevActiveFrameRate = stage.frameRate;
			stage.frameRate = _backgroundFrameRate;
		}
	}

	/**
	 *  @private
	 */
	private function nativeApplication_invokeHandler(event:InvokeEvent):void
	{
		// Because of the behavior with the nativeApplication invoke event
		// we queue events up until windowComplete
		if (invokesPending)
			initialInvokes.push(event);
		else
			dispatchEvent(event);
	}

	/**
	 * @private
	 */
	private function nativeWindow_activateHandler(event:Event):void
	{
		dispatchEvent(new AIREvent(AIREvent.WINDOW_ACTIVATE));
	}

	/**
	 *  @private
	 */
	private function nativeWindow_deactivateHandler(event:Event):void
	{
		dispatchEvent(new AIREvent(AIREvent.WINDOW_DEACTIVATE));
	}

	/**
	 *  This is a temporary event handler which dispatches a initialLayoutComplete event after
	 *  two updateCompletes. This event will only be dispatched after either setting the bounds or
	 *  maximizing the window at startup.
	 *
	 *  @langversion 3.0
	 *  @playerversion AIR 1.5
	 *  @productversion Flex 4
	 */
	private function updateComplete_handler(event:FlexEvent):void
	{
		if (ucCount == 1)
		{
			dispatchEvent(new Event("initialLayoutComplete"));
			removeEventListener(FlexEvent.UPDATE_COMPLETE, updateComplete_handler);
		}
		else
		{
			ucCount++;
		}
	}
}
}