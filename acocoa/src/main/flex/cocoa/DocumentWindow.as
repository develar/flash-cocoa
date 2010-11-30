package cocoa {
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.events.NativeWindowBoundsEvent;

import mx.core.FlexGlobals;
import mx.core.mx_internal;
import mx.managers.WindowedSystemManager;

import org.flyti.plexus.LocalEventMap;

use namespace mx_internal;

public class DocumentWindow {
  private static const DEFAULT_INIT_OPTIONS:NativeWindowInitOptions = new NativeWindowInitOptions();

  public function DocumentWindow(initOptions:NativeWindowInitOptions = null) {
    if (initOptions == null) {
      initOptions = DEFAULT_INIT_OPTIONS;
    }
    _nativeWindow = new NativeWindow(initOptions);
  }

  private var _maps:Vector.<LocalEventMap>;
  public function set maps(value:Vector.<LocalEventMap>):void {
    _maps = value;
  }

  private var _nativeWindow:NativeWindow;

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

//  public function get contentView():spark.components.supportClasses.Skin
  public function set contentView(component:Component):void {
    _contentView = component.createView(LookAndFeelProvider(FlexGlobals.topLevelApplication).laf);
    var sm:WindowedSystemManager = new WindowedSystemManager(_contentView);
    _nativeWindow.stage.addChild(sm);

    if (_maps != null) {
      // todo one plexus container for all maps
      _maps[0].dispatcher = _contentView;
    }

    _nativeWindow.addEventListener(NativeWindowBoundsEvent.RESIZE, windowResizeHandler);
    _nativeWindow.maximize();
    _nativeWindow.activate();
  }

  private function windowResizeHandler(event:NativeWindowBoundsEvent):void {
    _contentView.invalidateDisplayList();
    _contentView.setActualSize(_nativeWindow.stage.stageWidth, _nativeWindow.stage.stageHeight);
    _contentView.validateNow();
  }
}
}