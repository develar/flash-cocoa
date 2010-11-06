package cocoa {
import flash.display.NativeWindow;
import flash.display.NativeWindowDisplayState;
import flash.display.NativeWindowInitOptions;
import flash.events.Event;
import flash.events.NativeWindowBoundsEvent;
import flash.events.NativeWindowDisplayStateEvent;
import flash.geom.Rectangle;

import mx.core.IFlexDisplayObject;
import mx.core.IWindow;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.CursorManagerImpl;
import mx.managers.FocusManager;
import mx.managers.IActiveWindowManager;
import mx.managers.ICursorManager;
import mx.managers.IFocusManagerContainer;
import mx.managers.ISystemManager;
import mx.managers.SystemManagerGlobals;
import mx.managers.WindowedSystemManager;

import org.flyti.plexus.LocalEventMap;

use namespace mx_internal;

[Frame(factoryClass="mx.managers.WindowedSystemManager")]

public class DocumentWindow extends Container implements IWindow, IFocusManagerContainer {
  public function DocumentWindow() {
    super();

    addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);

    invalidateProperties();
  }

  protected var maps:Vector.<LocalEventMap>;

  private var _nativeWindow:NativeWindow;
  private var _nativeWindowVisible:Boolean = true;

  private var _cursorManager:ICursorManager;

  /**
   *  Ensures that the Window has finished drawing
   *  before it becomes visible.
   */
  private var frameCounter:int = 0;

  private var flagForOpen:Boolean = false;

  private var openActive:Boolean = true;

  /**
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
   */
  override public function get visible():Boolean {
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
    if (_nativeWindow == null) {
      _nativeWindowVisible = value;
      invalidateProperties();
    }
    else if (!_nativeWindow.closed) {
      _nativeWindow.visible = value;
    }

    // now call super.setVisible
    super.setVisible(value, noEvent);
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

  override protected function commitProperties():void {
    if (flagForOpen && _nativeWindow == null) {
      flagForOpen = false;

      // Set up our module factory if we don't have one.
      if (moduleFactory == null) {
        moduleFactory = SystemManagerGlobals.topLevelSystemManagers[0];
      }

      var init:NativeWindowInitOptions = new NativeWindowInitOptions();
      _nativeWindow = new NativeWindow(init);
      if (toMax) {
        _nativeWindow.maximize();
      }
      if (_title != null) {
        _nativeWindow.title = _title;
      }
      var sm:WindowedSystemManager = new WindowedSystemManager(this);
      _nativeWindow.stage.addChild(sm);
      systemManager = sm;
      sm.window = this;
      initManagers(sm);
      addEventListener(Event.ENTER_FRAME, enterFrameHandler);
      //'register' with WindowedSystemManager so it can cleanup when done.
      sm.addWindow(this);
    }

    // Moved the super.commitProperites() to here to allow the Window subclass to be
    // initialized. Part of the initialization is loading the skin of the Window subclass.
    // At this point we can call into SkinnableComponent.commitProperties without getting
    // a "skin was not found" error.
    super.commitProperties();
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

  private var toMax:Boolean;
  public function maximize():void {
    if (nativeWindow == null) {
      toMax = true;
    }
    else {
      nativeWindow.maximize();
    }
  }

  public function minimize():void {
    nativeWindow.minimize();
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
   * Activates the underlying NativeWindow (even if this Window's application is not currently active).
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

  private function enterFrameHandler(e:Event):void {
    if (frameCounter == 2) {
      removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
      _nativeWindow.visible = _nativeWindowVisible;

      if (_nativeWindow.visible) {
        if (openActive) {
          _nativeWindow.activate();
        }
      }
    }
    frameCounter++;
  }

  private function window_displayStateChangeHandler(event:NativeWindowDisplayStateEvent):void {
    // Redispatch event .
    dispatchEvent(event);

    height = stage.stageHeight;
    width = stage.stageWidth;

    // If we have been maximized or restored then invalidate so we can resize.
    if (event.afterDisplayState == NativeWindowDisplayState.MAXIMIZED || event.afterDisplayState == NativeWindowDisplayState.NORMAL) {
      invalidateSize();
      invalidateDisplayList();
    }
  }

  private function creationCompleteHandler(event:Event = null):void {
    systemManager.stage.nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, window_resizeHandler);
  }

  override public function initialize():void {
    super.initialize();

    systemManager.stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, window_displayStateChangeHandler);

    if (maps != null) {
      for each (var map:LocalEventMap in maps) {
        if (map.dispatcher == null) {
          map.dispatcher = this;
        }
      }
    }
  }

  private function window_resizeHandler(event:NativeWindowBoundsEvent):void {
    invalidateDisplayList();
    setActualSize(stage.stageWidth, stage.stageHeight);
    validateNow();
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
