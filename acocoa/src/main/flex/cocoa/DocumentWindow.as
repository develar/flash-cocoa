package cocoa {
import cocoa.plaf.Skin;

import flash.display.DisplayObject;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.Screen;
import flash.events.NativeWindowBoundsEvent;
import flash.geom.Rectangle;

import org.flyti.plexus.LocalEventMap;

public class DocumentWindow extends NativeWindow {
  private static const DEFAULT_INIT_OPTIONS:NativeWindowInitOptions = new NativeWindowInitOptions();

  public function DocumentWindow(contentView:Component, map:LocalEventMap, bounds:Rectangle = null, focusManager:FocusManager = null, initOptions:NativeWindowInitOptions = null) {
    super(initOptions || DEFAULT_INIT_OPTIONS);
    _focusManager = focusManager;
    
    init(contentView, map, bounds);
  }

  // keep link
  //noinspection JSFieldCanBeLocal
  private var map:LocalEventMap;

  private var _focusManager:FocusManager;
  public function get focusManager():FocusManager {
    return _focusManager;
  }

  private var _contentView:Skin;
  public function get contentView():Component {
    return _contentView.hostComponent;
  }

  private function init(contentView:Component, map:LocalEventMap, bounds:Rectangle):void {
    if (bounds == null || Screen.getScreensForRectangle(bounds).length == 0) {
      bounds = Screen.mainScreen.visibleBounds;
    }

    //_contentView = contentView.createView(LookAndFeelProvider(SystemManagerGlobals.topLevelSystemManagers[0]).laf);

    if (map != null) {
      //map.dispatcher = _contentView;
      this.map = map;
    }

    WindowInitUtil.initStage(stage);
    if (focusManager is AbstractFocusManager) {
      AbstractFocusManager(focusManager).init(stage);
    }

    addEventListener(NativeWindowBoundsEvent.RESIZE, resizeHandler);
    this.bounds = bounds;
    activate();
  }
  
  override public function close():void {
    removeEventListener(NativeWindowBoundsEvent.RESIZE, resizeHandler);
    super.close();
  }

  private function resizeHandler(event:NativeWindowBoundsEvent):void {
    if (DisplayObject(_contentView).parent == null) {
      var sm:WindowedSystemManager = new WindowedSystemManager();
      stage.addChild(sm);
      //sm.init(_contentView);
    }
    else {
      //_contentView.setActualSize(stage.stageWidth, stage.stageHeight);
    }

    //_contentView.validateNow();
  }
}
}