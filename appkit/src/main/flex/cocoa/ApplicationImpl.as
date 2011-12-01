package cocoa {
import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.events.Event;
import flash.external.ExternalInterface;
import flash.system.Capabilities;
import flash.ui.ContextMenu;
import flash.utils.setInterval;

import mx.core.ContainerCreationPolicy;
import mx.core.FlexGlobals;
import mx.core.IInvalidating;
import mx.core.Singleton;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.ILayoutManager;
import mx.managers.ISystemManager;
import mx.utils.LoaderUtil;

import org.flyti.plexus.EventMap;
import org.flyti.plexus.PlexusManager;
import org.flyti.plexus.events.InjectorEvent;

use namespace mx_internal;

[DefaultProperty("mxmlContent")]
public class ApplicationImpl extends LayoutlessContainer implements Application {
  protected var maps:Vector.<EventMap>;

  private var resizeWidth:Boolean = true;
  private var resizeHeight:Boolean = true;
  private static var synchronousResize:Boolean = false;

  private var resizeHandlerAdded:Boolean = false;
  private var percentBoundsChanged:Boolean;

  private var mxmlContentCreated:Boolean = false;

  public function ApplicationImpl() {
    UIComponentGlobals.layoutManager = ILayoutManager(Singleton.getInstance("mx.managers::ILayoutManager"));
    UIComponentGlobals.layoutManager.usePhasedInstantiation = true;

    if (FlexGlobals.topLevelApplication == null) {
      FlexGlobals.topLevelApplication = this;
    }

    var version:Array = Capabilities.version.split(' ')[1].split(',');
    synchronousResize = (parseFloat(version[0]) > 10 || (parseFloat(version[0]) == 10 && parseFloat(version[1]) >= 1)) && (Capabilities.playerType != "Desktop");

    initializeMaps();
    if (maps != null) {
      maps.fixed = true;
    }

    invalidateProperties();
  }

  private var _creationPolicy:String = ContainerCreationPolicy.ALL;
  public function get creationPolicy():String {
    return _creationPolicy;
  }

  public function set creationPolicy(value:String):void {
    _creationPolicy = value;
  }

  private var _deferredContentCreated:Boolean;
  public function get deferredContentCreated():Boolean {
    return _deferredContentCreated;
  }

  private var _mxmlContent:Vector.<Viewable>;
  public function set mxmlContent(value:Vector.<Viewable>):void {
    _mxmlContent = value;
    if (creationPolicy == ContainerCreationPolicy.ALL) {
      createDeferredContent();
    }
  }

  private static function injectHandler(event:InjectorEvent):void {
    event.stopImmediatePropagation();
    PlexusManager.instance.container.checkInjectors(event);
  }

  public function createDeferredContent():void {
    if (mxmlContentCreated) {
      return;
    }

    // see comment in flex ChildManager: "During startup the top level window isn't added to the child list until late into the startup sequence."
    // поэтому мы сами слушаем это событие и сразу направляем в главный контейнер — так как main app всегда адресует на него (MateManager.instance.container), так как является корневым display object
    addEventListener(InjectorEvent.INJECT, injectHandler);

    if (_mxmlContent != null) {
      for each (var subview:Viewable in _mxmlContent) {
        addSubview(subview);
      }
      _mxmlContent = null;
    }

    mxmlContentCreated = true;
    _deferredContentCreated = true;
    dispatchEvent(new FlexEvent(FlexEvent.CONTENT_CREATION_COMPLETE));
  }

  protected function initializeMaps():void {

  }

  override public function set tabIndex(value:int):void {
  }

  mx_internal var _parameters:Object;

  /**
   *  An Object containing name-value
   *  pairs representing the parameters provided to this Application.
   *
   *  <p>You can use a for-in loop to extract all the names and values
   *  from the parameters Object.</p>
   *
   *  <p>There are two sources of parameters: the query string of the
   *  Application's URL, and the value of the FlashVars HTML parameter
   *  (this affects only the main Application).</p>
   *
   *  @langversion 3.0
   *  @playerversion Flash 10
   *  @playerversion AIR 1.5
   *  @productversion Flex 4
   */
  public function get parameters():Object {
    return _parameters;
  }

  mx_internal var _url:String;

  /**
   *  The URL from which this Application's SWF file was loaded
   */
  public function get url():String {
    return _url;
  }

  override protected function commitProperties():void {
    super.commitProperties();

    resizeWidth = isNaN(explicitWidth);
    resizeHeight = isNaN(explicitHeight);

    if (resizeWidth || resizeHeight) {
      resizeHandler(new Event(Event.RESIZE));

      if (!resizeHandlerAdded) {
        // weak reference
        systemManager.addEventListener(Event.RESIZE, resizeHandler, false, 0, true);
        resizeHandlerAdded = true;
      }
    }
    else if (resizeHandlerAdded) {
      systemManager.removeEventListener(Event.RESIZE, resizeHandler);
      resizeHandlerAdded = false;
    }

    if (percentBoundsChanged) {
      updateBounds();
      percentBoundsChanged = false;
    }
  }

  /**
   *  This is here so we get the this pointer set to Application.
   */
  private static function debugTickler():void {
    // We need some bytes of code in order to have a place to break.
    //noinspection JSUnusedLocalSymbols
    var i:int = 0;
  }

  /**
   *  Disable all the built-in items except "Print...".
   */
  private function initContextMenu():void {
    var defaultMenu:ContextMenu = new ContextMenu();
    defaultMenu.hideBuiltInItems();
    defaultMenu.builtInItems.print = true;
    contextMenu = defaultMenu;

    if (systemManager is InteractiveObject) {
      InteractiveObject(systemManager).contextMenu = defaultMenu;
    }
  }

  /**
   *  Triggered by a resize event of the stage. Sets the new width and height.
   *  After the SystemManager performs its function, it is only necessary to notify the children of the change.
   */
  private function resizeHandler(event:Event):void {
    // If we're already due to update our bounds on the next commitProperties pass, avoid the redundancy.
    if (!percentBoundsChanged) {
      updateBounds();

      // Update immediately when stage resizes so that we may appear in synch with the stage rather than visually "catching up".
      if (synchronousResize) {
        UIComponentGlobals.layoutManager.validateNow();
      }
    }
  }

  private function updateBounds():void {
    // When user has not specified any width/height, application assumes the size of the stage.
    // If developer has specified width/height, the application will not resize.
    // If developer has specified percent width/height, application will resize to the required value based on the current SystemManager's width/height.
    // If developer has specified min/max values, then application will not resize beyond those values.

    var w:Number;
    var h:Number;
    if (resizeWidth) {
      if (isNaN(percentWidth)) {
        w = DisplayObject(systemManager).width;
      }
      else {
        super.percentWidth = Math.min(Math.max(percentWidth, 0), 100);
        w = percentWidth * DisplayObject(systemManager).width / 100;
      }

      if (!isNaN(explicitMaxWidth)) {
        w = Math.min(w, explicitMaxWidth);
      }

      if (!isNaN(explicitMinWidth)) {
        w = Math.max(w, explicitMinWidth);
      }
    }
    else {
      w = width;
    }

    if (resizeHeight) {
      if (isNaN(percentHeight)) {
        h = DisplayObject(systemManager).height;
      }
      else {
        super.percentHeight = Math.min(Math.max(percentHeight, 0), 100);
        h = percentHeight * DisplayObject(systemManager).height / 100;
      }

      if (!isNaN(explicitMaxHeight)) {
        h = Math.min(h, explicitMaxHeight);
      }

      if (!isNaN(explicitMinHeight)) {
        h = Math.max(h, explicitMinHeight);
      }
    }
    else {
      h = height;
    }

    if (w != width || h != height) {
      invalidateProperties();
      invalidateSize();
    }

    setActualSize(w, h);

    invalidateDisplayList();
  }

  override protected function createChildren():void {
    var sm:ISystemManager = systemManager;

    _url = LoaderUtil.normalizeURL(sm.loaderInfo);
    _parameters = sm.loaderInfo.parameters;

    initContextMenu();

    // Stick a timer here so that we will execute script every 1.5s no matter what. This is strictly for the debugger to be able to halt.
    if (sm.isTopLevel() && Capabilities.isDebugger) {
      setInterval(debugTickler, 1500);
    }

    PlexusManager.instance.container.checkInjectors(new InjectorEvent(this));

    // ignore super — для app LaF ставиться явно
  }
}
}