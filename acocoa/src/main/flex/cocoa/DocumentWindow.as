package cocoa {
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import flash.display.DisplayObject;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.Screen;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.NativeWindowBoundsEvent;
import flash.geom.Rectangle;

import mx.managers.SystemManagerGlobals;

import org.flyti.plexus.LocalEventMap;

public class DocumentWindow {
  private static const DEFAULT_INIT_OPTIONS:NativeWindowInitOptions = new NativeWindowInitOptions();

  public function DocumentWindow(component:Component, map:LocalEventMap, initOptions:NativeWindowInitOptions = null, bounds:Rectangle = null) {
    if (initOptions == null) {
      initOptions = DEFAULT_INIT_OPTIONS;
    }
    _nativeWindow = new NativeWindow(initOptions);
    
    init(component, map, bounds || Screen.mainScreen.visibleBounds);
  }

  // keep link
  private var map:LocalEventMap;

  private var _nativeWindow:NativeWindow;
  public function get nativeWindow():NativeWindow {
    return _nativeWindow;
  }

  public function get title():String {
    return _nativeWindow.title;
  }

  public function set title(value:String):void {
    _nativeWindow.title = value;
  }

  private var _contentView:Skin;
  public function get contentView():Component {
    return _contentView.component;
  }

  private function init(component:Component, map:LocalEventMap, bounds:Rectangle):void {
    _contentView = component.createView(LookAndFeelProvider(SystemManagerGlobals.topLevelSystemManagers[0]).laf);

    if (map != null) {
      // todo one plexus container for all maps (or for document window must be only one map?)
      map.dispatcher = _contentView;
      this.map = map;
    }

    _nativeWindow.stage.scaleMode = StageScaleMode.NO_SCALE;
    _nativeWindow.stage.align = StageAlign.TOP_LEFT;

    _nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, windowResizeHandler);
    _nativeWindow.bounds = bounds;
    _nativeWindow.activate();
  }
  
  public function close():void {
    _nativeWindow.removeEventListener(NativeWindowBoundsEvent.RESIZE, windowResizeHandler);
    _nativeWindow.close();
    _nativeWindow = null;
  }

  private function windowResizeHandler(event:NativeWindowBoundsEvent):void {
    if (DisplayObject(_contentView).parent == null) {
      var sm:WindowedSystemManager = new WindowedSystemManager(_contentView);
       _nativeWindow.stage.addChild(sm);
      sm.init();
    }
    else {
      _contentView.setActualSize(_nativeWindow.stage.stageWidth, _nativeWindow.stage.stageHeight);
    }

    _contentView.validateNow();
  }
}
}