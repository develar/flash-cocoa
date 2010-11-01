package cocoa {
import flash.desktop.NativeApplication;
import flash.display.NativeWindow;
import flash.display.NativeWindowDisplayState;
import flash.display.NativeWindowInitOptions;
import flash.display.NativeWindowSystemChrome;
import flash.events.Event;
import flash.events.NativeWindowBoundsEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.FlexGlobals;
import mx.core.IFlexDisplayObject;
import mx.core.IWindow;
import mx.core.mx_internal;
import mx.events.AIREvent;
import mx.events.EffectEvent;
import mx.events.FlexEvent;
import mx.events.FlexNativeWindowBoundsEvent;
import mx.events.WindowExistenceEvent;
import mx.managers.CursorManagerImpl;
import mx.managers.FocusManager;
import mx.managers.IActiveWindowManager;
import mx.managers.ICursorManager;
import mx.managers.IFocusManagerContainer;
import mx.managers.ISystemManager;
import mx.managers.SystemManagerGlobals;
import mx.managers.WindowedSystemManager;

use namespace mx_internal;

/**
 *  Dispatched when this application gets activated.
 *
 *  @eventType mx.events.AIREvent.APPLICATION_ACTIVATE
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="applicationActivate", type="mx.events.AIREvent")]

/**
 *  Dispatched when this application gets deactivated.
 *
 *  @eventType mx.events.AIREvent.APPLICATION_DEACTIVATE
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="applicationDeactivate", type="mx.events.AIREvent")]

/**
 *  Dispatched after the window has been activated.
 *
 *  @eventType mx.events.AIREvent.WINDOW_ACTIVATE
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowActivate", type="mx.events.AIREvent")]

/**
 *  Dispatched after the window has been deactivated.
 *
 *  @eventType mx.events.AIREvent.WINDOW_DEACTIVATE
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowDeactivate", type="mx.events.AIREvent")]

/**
 *  Dispatched after the window has been closed.
 *
 *  @eventType flash.events.Event.CLOSE
 *
 *  @see flash.display.NativeWindow
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="close", type="flash.events.Event")]

/**
 *  Dispatched before the window closes.
 *  This event is cancelable.
 *
 *  @eventType flash.events.Event.CLOSING
 *
 *  @see flash.display.NativeWindow
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="closing", type="flash.events.Event")]

/**
 *  Dispatched after the display state changes
 *  to minimize, maximize or restore.
 *
 *  @eventType flash.events.NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="displayStateChange", type="flash.events.NativeWindowDisplayStateEvent")]

/**
 *  Dispatched before the display state changes
 *  to minimize, maximize or restore.
 *
 *  @eventType flash.events.NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="displayStateChanging", type="flash.events.NativeWindowDisplayStateEvent")]

/**
 *  Dispatched before the window moves,
 *  and while the window is being dragged.
 *
 *  @eventType flash.events.NativeWindowBoundsEvent.MOVING
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="moving", type="flash.events.NativeWindowBoundsEvent")]

/**
 *  Dispatched when the computer connects to or disconnects from the network.
 *
 *  @eventType flash.events.Event.NETWORK_CHANGE
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="networkChange", type="flash.events.Event")]

/**
 *  Dispatched before the underlying NativeWindow is resized, or
 *  while the Window object boundaries are being dragged.
 *
 *  @eventType flash.events.NativeWindowBoundsEvent.RESIZING
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="resizing", type="flash.events.NativeWindowBoundsEvent")]

/**
 *  Dispatched when the Window completes its initial layout
 *  and opens the underlying NativeWindow.
 *
 *  @eventType mx.events.AIREvent.WINDOW_COMPLETE
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowComplete", type="mx.events.AIREvent")]

/**
 *  Dispatched after the window moves.
 *
 *  @eventType mx.events.FlexNativeWindowBoundsEvent.WINDOW_MOVE
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowMove", type="mx.events.FlexNativeWindowBoundsEvent")]

/**
 *  Dispatched after the underlying NativeWindow is resized.
 *
 *  @eventType mx.events.FlexNativeWindowBoundsEvent.WINDOW_RESIZE
 *
 *  @langversion 3.0
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
[Event(name="windowResize", type="mx.events.FlexNativeWindowBoundsEvent")]

[Frame(factoryClass="mx.managers.WindowedSystemManager")]

public class DocumentWindow extends Container implements IWindow, IFocusManagerContainer {
  /**
   *  The default height for a window (SDK-14399)
   *  @private
   */
  private static const DEFAULT_WINDOW_HEIGHT:Number = 100;

  /**
   *  The default width for a window (SDK-14399)
   *  @private
   */
  private static const DEFAULT_WINDOW_WIDTH:Number = 100;

  public function DocumentWindow() {
    super();

    addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
    addEventListener(FlexEvent.PREINITIALIZE, preinitializeHandler);

    invalidateProperties();
  }

  private var _nativeWindow:NativeWindow;

  private var _nativeWindowVisible:Boolean = true;

  private var _cursorManager:ICursorManager;

  private var toMax:Boolean = false;

  /**
   *  Ensures that the Window has finished drawing
   *  before it becomes visible.
   */
  private var frameCounter:int = 0;

  private var flagForOpen:Boolean = false;

  private var openActive:Boolean = true;

  private var oldX:Number;

  private var oldY:Number;

  [Bindable("heightChanged")]
  [Inspectable(category="General")]
  [PercentProxy("percentHeight")]

  /**
   *  @private
   */ override public function get height():Number {
    return _bounds.height;
  }

  /**
   *  @private
   *  Also sets the stage's height.
   */
  override public function set height(value:Number):void {
    if (value < minHeight) {
      value = minHeight;
    }
    else {
      if (value > maxHeight) {
        value = maxHeight;
      }
    }

    _bounds.height = value;
    boundsChanged = true;

    invalidateProperties();
    invalidateSize();

    dispatchEvent(new Event("heightChanged"));
    // also dispatched in the resizeHandler
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
   */ override public function get maxHeight():Number {
    if (nativeWindow && !maxHeightChanged) {
      return nativeWindow.maxSize.y - chromeHeight();
    }
    else {
      return _maxHeight;
    }
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
  override public function set maxHeight(value:Number):void {
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
   */ override public function get maxWidth():Number {
    if (nativeWindow && !maxWidthChanged) {
      return nativeWindow.maxSize.x - chromeWidth();
    }
    else {
      return _maxWidth;
    }
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
  override public function set maxWidth(value:Number):void {
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
   */ override public function get minHeight():Number {
    if (nativeWindow && !minHeightChanged) {
      return nativeWindow.minSize.y - chromeHeight();
    }
    else {
      return _minHeight;
    }
  }

  /**
   *  @private
   */
  override public function set minHeight(value:Number):void {
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
   */ override public function get minWidth():Number {
    if (nativeWindow && !minWidthChanged) {
      return nativeWindow.minSize.x - chromeWidth();
    }
    else {
      return _minWidth;
    }
  }

  /**
   *  @private
   */
  override public function set minWidth(value:Number):void {
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
   *  Controls the window's visibility. Unlike the
   *  <code>UIComponent.visible</code> property of most Flex
   *  visual components, this property affects the visibility
   *  of the underlying NativeWindow (including operating system
   *  chrome) as well as the visibility of the Window's child
   *  controls.
   *
   *  <p>When this property changes, Flex dispatches a <code>show</code>
   *  or <code>hide</code> event.</p>
   *
   *  @default true
   *
   *  @langversion 3.0
   *  @playerversion AIR 1.5
   *  @productversion Flex 4
   */ override public function get visible():Boolean {
    if (nativeWindow && nativeWindow.closed) {
      return false;
    }
    if (nativeWindow) {
      return nativeWindow.visible;
    }
    else {
      return _nativeWindowVisible;
    }
  }

  /**
   *  @private
   */
  override public function set visible(value:Boolean):void {
    setVisible(value);
  }

  /**
   *  @private
   *  We override setVisible because there's the flash display object concept
   *  of visibility and also the nativeWindow concept of visibility.
   */
  override public function setVisible(value:Boolean, noEvent:Boolean = false):void {
    // first handle the native window stuff
    if (!_nativeWindow) {
      _nativeWindowVisible = value;
      invalidateProperties();
    }
    else {
      if (!_nativeWindow.closed) {
        if (value) {
          _nativeWindow.visible = value;
        }
        else {
          // in the conditions below we will play an effect
          if (getStyle("hideEffect") && initialized && $visible != value) {
            addEventListener(EffectEvent.EFFECT_END, hideEffectEndHandler);
          }
          else {
            _nativeWindow.visible = value;
          }
        }
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
   */ override public function get width():Number {
    return _bounds.width;
  }

  /**
   *  @private
   *  Also sets the stage's width.
   */
  override public function set width(value:Number):void {
    if (value < minWidth) {
      value = minWidth;
    }
    else {
      if (value > maxWidth) {
        value = maxWidth;
      }
    }

    _bounds.width = value;
    boundsChanged = true;

    invalidateProperties();
    invalidateSize();

    dispatchEvent(new Event("widthChanged"));
    // also dispatched in the resize handler
  }

  private var _bounds:Rectangle = new Rectangle(0, 0, DEFAULT_WINDOW_WIDTH, DEFAULT_WINDOW_HEIGHT);

  private var boundsChanged:Boolean = false;

  /**
   *  @private
   *  A Rectangle specifying the window's bounds
   *  relative to the screen.
   */
  protected function get bounds():Rectangle {
    return _bounds;
  }

  protected function set bounds(value:Rectangle):void {
    _bounds = value;
    boundsChanged = true;

    invalidateProperties();
    invalidateSize();
  }

  override public function get cursorManager():ICursorManager {
    return _cursorManager;
  }

  public function get nativeWindow():NativeWindow {
    if (systemManager && systemManager.stage) {
      return systemManager.stage.nativeWindow;
    }

    return null;
  }

  override protected function createChildren():void {
    // this is to help initialize the stage
    width = _bounds.width;
    height = _bounds.height;

    super.createChildren();
  }

  override protected function commitProperties():void {
    if (flagForOpen && !_nativeWindow) {
      flagForOpen = false;

      // Set up our module factory if we don't have one.
      if (moduleFactory == null) {
        moduleFactory = SystemManagerGlobals.topLevelSystemManagers[0];
      }

      var init:NativeWindowInitOptions = new NativeWindowInitOptions();

      _nativeWindow = new NativeWindow(init);
      if (_title != null) {
        _nativeWindow.title = _title;
      }
      var sm:WindowedSystemManager = new WindowedSystemManager(this);
      _nativeWindow.stage.addChild(sm);
      systemManager = sm;

      sm.window = this;

      initManagers(sm);

      var nativeApplication:NativeApplication = NativeApplication.nativeApplication;
      nativeApplication.addEventListener(Event.ACTIVATE, nativeApplication_activateHandler, false, 0, true);
      nativeApplication.addEventListener(Event.DEACTIVATE, nativeApplication_deactivateHandler, false, 0, true);
      nativeApplication.addEventListener(Event.NETWORK_CHANGE, dispatchEvent, false, 0, true);
      _nativeWindow.addEventListener(Event.ACTIVATE, nativeWindow_activateHandler, false, 0, true);
      _nativeWindow.addEventListener(Event.DEACTIVATE, nativeWindow_deactivateHandler, false, 0, true);

      addEventListener(Event.ENTER_FRAME, enterFrameHandler);

      //'register' with WindowedSystemManager so it can cleanup when done.
      sm.addWindow(this);
    }

    // Moved the super.commitProperites() to here to allow the Window subclass to be
    // initialized. Part of the initialization is loading the skin of the Window subclass.
    // At this point we can call into SkinnableComponent.commitProperties without getting
    // a "skin was not found" error.
    super.commitProperties();

    // AIR won't allow you to set the min width greater than the current
    // max width (same is true for height). You also can't set the max
    // width less than the current min width (same is true for height).
    // This makes the updating of the new minSize and maxSize a bit tricky.
    if (minWidthChanged || minHeightChanged || maxWidthChanged || maxHeightChanged) {
      var minSize:Point = nativeWindow.minSize;
      var maxSize:Point = nativeWindow.maxSize;
      var newMinWidth:Number = minWidthChanged ? _minWidth + chromeWidth() : minSize.x;
      var newMinHeight:Number = minHeightChanged ? _minHeight + chromeHeight() : minSize.y;
      var newMaxWidth:Number = maxWidthChanged ? _maxWidth + chromeWidth() : maxSize.x;
      var newMaxHeight:Number = maxHeightChanged ? _maxHeight + chromeHeight() : maxSize.y;

      if (minWidthChanged || minHeightChanged) {
        // If the new min size is greater than the old max size, then
        // we need to set the new max size now.
        if ((maxWidthChanged && newMinWidth > minSize.x) || (maxHeightChanged && newMinHeight > minSize.y)) {
          nativeWindow.maxSize = new Point(newMaxWidth, newMaxHeight);
        }

        nativeWindow.minSize = new Point(newMinWidth, newMinHeight);
      }

      // Set the max width or height if it is not already set. The max
      // width and height could have been set above when setting minSize
      // but the max size would have been rejected by AIR if it were less
      // than the old min size.
      if (newMaxWidth != maxSize.x || newMaxHeight != maxSize.y) {
        nativeWindow.maxSize = new Point(newMaxWidth, newMaxHeight);
      }
    }

    // minimum width and height
    if (minWidthChanged || minHeightChanged) {
      if (minWidthChanged) {
        minWidthChanged = false;
        if (width < minWidth) {
          width = minWidth;
        }
        dispatchEvent(new Event("minWidthChanged"));
      }
      if (minHeightChanged) {
        minHeightChanged = false;
        if (height < minHeight) {
          height = minHeight;
        }
        dispatchEvent(new Event("minHeightChanged"));
      }
    }

    // maximum width and height
    if (maxWidthChanged || maxHeightChanged) {
      if (maxWidthChanged) {
        maxWidthChanged = false;
        if (width > maxWidth) {
          width = maxWidth;
        }
        dispatchEvent(new Event("maxWidthChanged"));
      }
      if (maxHeightChanged) {
        maxHeightChanged = false;
        if (height > maxHeight) {
          height = maxHeight;
        }
        dispatchEvent(new Event("maxHeightChanged"));
      }
    }

    if (boundsChanged) {
      // Work around an AIR issue setting the stageHeight to zero when
      // using system chrome. The set of the stage.stageHeight property
      // is rejected unless the nativeWindow is first set to the proper
      // height.
      // Don't perform this workaround if the window has zero height due
      // to being minimized. Setting the nativeWindow height to non-zero
      // causes AIR to restore the window.
      if (_bounds.height == 0 && nativeWindow.displayState != NativeWindowDisplayState.MINIMIZED && systemChrome == NativeWindowSystemChrome.STANDARD) {
        nativeWindow.height = chromeHeight() + _bounds.height;
      }

      // Set _width and _height.  This will update the mirroring
      // transform if applicable.
      setActualSize(_bounds.width, _bounds.height);

      // We use temporary variables because when we set stageWidth or
      // stageHeight _bounds will be overwritten when we receive
      // a RESIZE event.
      var newWidth:Number = _bounds.width;
      var newHeight:Number = _bounds.height;
      systemManager.stage.stageWidth = newWidth;
      systemManager.stage.stageHeight = newHeight;
      boundsChanged = false;
    }

    if (toMax) {
      toMax = false;
      if (!nativeWindow.closed) {
        nativeWindow.maximize();
      }
    }
  }

  override public function move(x:Number, y:Number):void {
    if (nativeWindow && !nativeWindow.closed) {
      var tmp:Rectangle = nativeWindow.bounds;
      tmp.x = x;
      tmp.y = y;
      nativeWindow.bounds = tmp;
    }
  }

  public function close():void {
    if (_nativeWindow && !nativeWindow.closed) {
      var e:Event = new Event("closing", false, true);
      stage.nativeWindow.dispatchEvent(e);
      if (!(e.isDefaultPrevented())) {
        stage.nativeWindow.close();
        _nativeWindow = null;
        systemManager.removeChild(this);
      }
    }
  }

  private function initManagers(sm:ISystemManager):void {
    if (sm.isTopLevel()) {
      focusManager = new FocusManager(this);
      var awm:IActiveWindowManager = IActiveWindowManager(sm.getImplementation("mx.managers::IActiveWindowManager"));
      if (awm) {
        awm.activate(this);
      }
      else {
        focusManager.activate();
      }
      _cursorManager = new CursorManagerImpl(sm);
    }
  }

  public function maximize():void {
    if (!nativeWindow || !nativeWindow.maximizable || nativeWindow.closed) {
      return;
    }
    if (stage.nativeWindow.displayState != NativeWindowDisplayState.MAXIMIZED) {
      var f:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, false, true, stage.nativeWindow.displayState, NativeWindowDisplayState.MAXIMIZED);
      stage.nativeWindow.dispatchEvent(f);
      if (!f.isDefaultPrevented()) {
        toMax = true;
        invalidateProperties();
      }
    }
  }

  public function minimize():void {
    if (!nativeWindow.minimizable) {
      return;
    }

    if (!nativeWindow.closed) {
      var e:NativeWindowDisplayStateEvent = new NativeWindowDisplayStateEvent(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, false, true, nativeWindow.displayState, NativeWindowDisplayState.MINIMIZED);
      stage.nativeWindow.dispatchEvent(e);
      if (!e.isDefaultPrevented()) {
        stage.nativeWindow.minimize();
      }
    }
  }

  public function restore():void {
    if (!nativeWindow.closed) {
      var e:NativeWindowDisplayStateEvent;
      if (stage.nativeWindow.displayState == NativeWindowDisplayState.MAXIMIZED) {
        e = new NativeWindowDisplayStateEvent(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, false, true, NativeWindowDisplayState.MAXIMIZED, NativeWindowDisplayState.NORMAL);
        stage.nativeWindow.dispatchEvent(e);
        if (!e.isDefaultPrevented()) {
          nativeWindow.restore();
        }
      }
      else {
        if (stage.nativeWindow.displayState == NativeWindowDisplayState.MINIMIZED) {
          e = new NativeWindowDisplayStateEvent(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, false, true, NativeWindowDisplayState.MINIMIZED, NativeWindowDisplayState.NORMAL);
          stage.nativeWindow.dispatchEvent(e);
          if (!e.isDefaultPrevented()) {
            nativeWindow.restore();
          }
        }
      }
    }
  }

  /**
   *  Activates the underlying NativeWindow (even if this Window's application
   *  is not currently active).
   *
   *  @langversion 3.0
   *  @playerversion AIR 1.5
   *  @productversion Flex 4
   */
  public function activate():void {
    if (!nativeWindow.closed) {
      _nativeWindow.activate();
    }
  }

  /**
   *  Creates the underlying NativeWindow and opens it.
   *
   *  After being closed, the Window object is still a valid reference, but
   *  accessing most properties and methods will not work.
   *  Closed windows cannot be reopened.
   *
   *  @param  openWindowActive specifies whether the Window opens
   *  activated (that is, whether it has focus). The default value
   *  is <code>true</code>.
   *
   *  @langversion 3.0
   *  @playerversion AIR 1.5
   *  @productversion Flex 4
   */
  public function open(openWindowActive:Boolean = true):void {
    flagForOpen = true;
    openActive = openWindowActive;
    commitProperties();
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
  public function orderToFront():Boolean {
    if (nativeWindow && !nativeWindow.closed) {
      return nativeWindow.orderToFront();
    }
    else {
      return false;
    }
  }

  private function chromeWidth():Number {
    return nativeWindow.width - systemManager.stage.stageWidth;
  }

  /**
   *  @private
   *  Returns the height of the chrome for the window
   */
  private function chromeHeight():Number {
    return nativeWindow.height - systemManager.stage.stageHeight;
  }

  private function enterFrameHandler(e:Event):void {
    if (frameCounter == 2) {
      removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
      _nativeWindow.visible = _nativeWindowVisible;
      dispatchEvent(new AIREvent(AIREvent.WINDOW_COMPLETE));

      // Event for Automation so we know when windows
      // are created or destroyed.
      if (FlexGlobals.topLevelApplication) {
        FlexGlobals.topLevelApplication.dispatchEvent(new WindowExistenceEvent(WindowExistenceEvent.WINDOW_CREATE, false, false, this));
      }

      if (_nativeWindow.visible) {
        if (openActive) {
          _nativeWindow.activate();
        }
      }
    }
    frameCounter++;
  }

  /**
   *  @private
   */
  private function hideEffectEndHandler(event:Event):void {
    if (!_nativeWindow.closed) {
      _nativeWindow.visible = false;
    }
    removeEventListener(EffectEvent.EFFECT_END, hideEffectEndHandler);
  }

  /**
   *  @private
   */
  private function windowMinimizeHandler(event:Event):void {
    if (!nativeWindow.closed) {
      stage.nativeWindow.minimize();
    }
    removeEventListener(EffectEvent.EFFECT_END, windowMinimizeHandler);
  }

  /**
   *  @private
   */
  private function windowUnminimizeHandler(event:Event):void {
    removeEventListener(EffectEvent.EFFECT_END, windowUnminimizeHandler);
  }

  /**
   *  @private
   */
  private function window_moveHandler(event:NativeWindowBoundsEvent):void {
    var newEvent:FlexNativeWindowBoundsEvent = new FlexNativeWindowBoundsEvent(FlexNativeWindowBoundsEvent.WINDOW_MOVE, event.bubbles, event.cancelable, event.beforeBounds, event.afterBounds);
    dispatchEvent(newEvent);
  }

  /**
   *  @private
   */
  private function window_displayStateChangeHandler(event:NativeWindowDisplayStateEvent):void {
    // Redispatch event .
    dispatchEvent(event);

    height = stage.stageHeight;
    width = stage.stageWidth;

    // Restored from a minimized state.
    if (event.beforeDisplayState == NativeWindowDisplayState.MINIMIZED) {
      addEventListener(EffectEvent.EFFECT_END, windowUnminimizeHandler);
      dispatchEvent(new Event("windowUnminimize"));
    }

    // If we have been maximized or restored then invalidate so we can
    // resize.
    if (event.afterDisplayState == NativeWindowDisplayState.MAXIMIZED || event.afterDisplayState == NativeWindowDisplayState.NORMAL) {
      invalidateSize();
      invalidateDisplayList();
    }

  }

  /**
   *  @private
   */
  private function window_displayStateChangingHandler(event:NativeWindowDisplayStateEvent):void {
    // Redispatch event for cancellation purposes.
    dispatchEvent(event);

    if (event.isDefaultPrevented()) {
      return;
    }
    if (event.afterDisplayState == NativeWindowDisplayState.MINIMIZED) {
      if (getStyle("minimizeEffect")) {
        event.preventDefault();
        addEventListener(EffectEvent.EFFECT_END, windowMinimizeHandler);
        dispatchEvent(new Event("windowMinimize"));
      }
    }

  }

  private function creationCompleteHandler(event:Event = null):void {
    systemManager.stage.nativeWindow.addEventListener("closing", window_closingHandler);

    systemManager.stage.nativeWindow.addEventListener("close", window_closeHandler, false, 0, true);

    systemManager.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVING, window_boundsHandler);

    systemManager.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.MOVE, window_moveHandler);

    systemManager.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZING, window_boundsHandler);

    systemManager.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, window_resizeHandler);

  }

  private function preinitializeHandler(event:FlexEvent):void {
    systemManager.stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGING, window_displayStateChangingHandler);
    systemManager.stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, window_displayStateChangeHandler);
  }

  private function window_boundsHandler(event:NativeWindowBoundsEvent):void {

    var newBounds:Rectangle = event.afterBounds;

    if (event.type == NativeWindowBoundsEvent.MOVING) {
      dispatchEvent(event);
      if (event.isDefaultPrevented()) {
        return;
      }
    }
    else //event is resizing
    {
      dispatchEvent(event);
      if (event.isDefaultPrevented()) {
        return;
      }
      var cancel:Boolean = false;
      if (newBounds.width < nativeWindow.minSize.x) {
        cancel = true;
        if (newBounds.x != event.beforeBounds.x && !isNaN(oldX)) {
          newBounds.x = oldX;
        }
        newBounds.width = nativeWindow.minSize.x;
      }
      else {
        if (newBounds.width > nativeWindow.maxSize.x) {
          cancel = true;
          if (newBounds.x != event.beforeBounds.x && !isNaN(oldX)) {
            newBounds.x = oldX;
          }
          newBounds.width = nativeWindow.maxSize.x;
        }
      }
      if (newBounds.height < nativeWindow.minSize.y) {
        cancel = true;
        if (event.afterBounds.y != event.beforeBounds.y && !isNaN(oldY)) {
          newBounds.y = oldY;
        }
        newBounds.height = nativeWindow.minSize.y;
      }
      else {
        if (newBounds.height > nativeWindow.maxSize.y) {
          cancel = true;
          if (event.afterBounds.y != event.beforeBounds.y && !isNaN(oldY)) {
            newBounds.y = oldY;
          }
          newBounds.height = nativeWindow.maxSize.y;
        }
      }
      if (cancel) {
        event.preventDefault();
        stage.nativeWindow.bounds = newBounds;
      }
    }
    oldX = newBounds.x;
    oldY = newBounds.y;
  }

  /**
   *  @private
   */
  private function window_closeEffectEndHandler(event:Event):void {
    removeEventListener(EffectEvent.EFFECT_END, window_closeEffectEndHandler);
    if (!nativeWindow.closed) {
      stage.nativeWindow.close();
    }
  }

  /**
   *  @private
   */
  private function window_closingHandler(event:Event):void {
    var e:Event = new Event("closing", true, true);
    dispatchEvent(e);
    if (e.isDefaultPrevented()) {
      event.preventDefault();
    }
    else {
      if (getStyle("closeEffect") && stage.nativeWindow.transparent) {
        addEventListener(EffectEvent.EFFECT_END, window_closeEffectEndHandler);
        dispatchEvent(new Event("windowClose"));
        event.preventDefault();
      }
    }
  }

  /**
   *  @private
   */
  private function window_closeHandler(event:Event):void {
    dispatchEvent(new Event("close"));

    // Event for Automation so we know when windows
    // are created or destroyed.
    if (FlexGlobals.topLevelApplication) {
      FlexGlobals.topLevelApplication.dispatchEvent(new WindowExistenceEvent(WindowExistenceEvent.WINDOW_CLOSE, false, false, this));
    }
  }

  private function window_resizeHandler(event:NativeWindowBoundsEvent):void {
    invalidateDisplayList();

    var dispatchWidthChangeEvent:Boolean = (bounds.width != stage.stageWidth);
    var dispatchHeightChangeEvent:Boolean = (bounds.height != stage.stageHeight);

    bounds.x = stage.x;
    bounds.y = stage.y;
    bounds.width = stage.stageWidth;
    bounds.height = stage.stageHeight;

    // Set _width and _height.  This will update the mirroring
    // transform if applicable.
    setActualSize(_bounds.width, _bounds.height);

    validateNow();
    var e:FlexNativeWindowBoundsEvent = new FlexNativeWindowBoundsEvent(FlexNativeWindowBoundsEvent.WINDOW_RESIZE, event.bubbles, event.cancelable, event.beforeBounds, event.afterBounds);
    dispatchEvent(e);

    if (dispatchWidthChangeEvent) {
      dispatchEvent(new Event("widthChanged"));
    }
    if (dispatchHeightChangeEvent) {
      dispatchEvent(new Event("heightChanged"));
    }
  }

  private function nativeApplication_activateHandler(event:Event):void {
    dispatchEvent(new AIREvent(AIREvent.APPLICATION_ACTIVATE));
  }

  private function nativeApplication_deactivateHandler(event:Event):void {
    dispatchEvent(new AIREvent(AIREvent.APPLICATION_DEACTIVATE));
  }

  private function nativeWindow_activateHandler(event:Event):void {
    dispatchEvent(new AIREvent(AIREvent.WINDOW_ACTIVATE));
  }

  private function nativeWindow_deactivateHandler(event:Event):void {
    dispatchEvent(new AIREvent(AIREvent.WINDOW_DEACTIVATE));
  }

  public function get maximizable():Boolean {
    return false;
  }

  public function get minimizable():Boolean {
    return false;
  }

  public function get resizable():Boolean {
    return false;
  }

  public function get status():String {
    return null;
  }

  public function set status(value:String):void {
  }

  public function get systemChrome():String {
    return null;
  }

  public function get title():String {
    return _nativeWindow == null ? _title : _nativeWindow.title;
  }

  private var _title:String;
  public function set title(value:String):void {
    if (_nativeWindow == null) {
      _title = value;
    }
    else {
      _nativeWindow.title = value;
    }
  }

  public function get titleIcon():Class {
    return null;
  }

  public function set titleIcon(value:Class):void {
  }

  public function get transparent():Boolean {
    return false;
  }

  public function get type():String {
    return null;
  }

  public function get defaultButton():IFlexDisplayObject {
    return null;
  }

  public function set defaultButton(value:IFlexDisplayObject):void {
  }
}
}
