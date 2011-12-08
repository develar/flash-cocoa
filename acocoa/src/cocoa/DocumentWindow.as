package cocoa {
import flash.display.DisplayObject;
import flash.display.NativeWindow;
import flash.display.NativeWindowInitOptions;
import flash.display.Screen;
import flash.events.NativeWindowBoundsEvent;
import flash.geom.Rectangle;

import org.flyti.plexus.LocalEventMap;

public class DocumentWindow extends NativeWindow {
  private static const DEFAULT_INIT_OPTIONS:NativeWindowInitOptions = new NativeWindowInitOptions();

  public function DocumentWindow(contentView:RootContentView, map:LocalEventMap, bounds:Rectangle = null, focusManager:FocusManager = null, initOptions:NativeWindowInitOptions = null) {
    super(initOptions || DEFAULT_INIT_OPTIONS);
    _focusManager = focusManager;
    _contentView = contentView;
    init(map, bounds);
  }

  // keep link
  //noinspection JSFieldCanBeLocal
  private var map:LocalEventMap;

  private var _focusManager:FocusManager;
  public function get focusManager():FocusManager {
    return _focusManager;
  }

  private var _contentView:RootContentView;
  public function get contentView():RootContentView {
    return _contentView;
  }

  private function init(map:LocalEventMap, bounds:Rectangle):void {
    if (bounds == null || Screen.getScreensForRectangle(bounds).length == 0) {
      bounds = Screen.mainScreen.visibleBounds;
    }

    if (map != null) {
      map.dispatcher = _contentView.displayObject;
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
    var displayObject:DisplayObject = _contentView.displayObject;
    if (displayObject.parent == null) {
      stage.addChild(displayObject);
    }

    _contentView.preferredWidth = stage.stageWidth;
    _contentView.preferredHeight = stage.stageHeight;

    _contentView.validate();
  }
}
}