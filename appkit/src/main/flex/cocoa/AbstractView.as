package cocoa {
import cocoa.layout.LayoutMetrics;

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.display.Stage;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.IEventDispatcher;
import flash.geom.Matrix;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;

import mx.core.DesignLayer;
import mx.core.IInvalidating;
import mx.core.IUIComponent;
import mx.core.IVisualElement;
import mx.core.LayoutElementUIComponentUtils;
import mx.core.UIComponent;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.events.MoveEvent;
import mx.events.PropertyChangeEvent;
import mx.events.ResizeEvent;
import mx.filters.BaseFilter;
import mx.filters.IBitmapFilter;
import mx.geom.TransformOffsets;
import mx.graphics.shaderClasses.ColorBurnShader;
import mx.graphics.shaderClasses.ColorDodgeShader;
import mx.graphics.shaderClasses.ColorShader;
import mx.graphics.shaderClasses.ExclusionShader;
import mx.graphics.shaderClasses.HueShader;
import mx.graphics.shaderClasses.LuminosityShader;
import mx.graphics.shaderClasses.SaturationShader;
import mx.graphics.shaderClasses.SoftLightShader;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerComponent;
import mx.managers.IFocusManagerContainer;
import mx.managers.ILayoutManagerClient;
import mx.managers.ISystemManager;

use namespace mx_internal;
[Abstract]
public class AbstractView extends Sprite implements View, ILayoutManagerClient, IVisualElement {
  public static const LAYOUT_DIRECTION_LTR:String = "ltr";

  private static const EMPTY_LAYOUT_METRICS:LayoutMetrics = new LayoutMetrics();

  private static const INITIALIZED:uint = 1 << 0;
  private static const DISABLED:uint = 1 << 11;
  private static const EXCLUDE_FROM_LAYOUT:uint = 1 << 12;
  private static const PROCESSED_DESCRIPTORS:uint = 1 << 3;
  private static const UPDATE_COMPLETE_PENDING:uint = 1 << 4;

  private static const INVALID_PROPERTIES:uint = 1 << 5;
  private static const INVALID_SIZE:uint = 1 << 6;
  private static const INVALID_DISPLAY_LIST:uint = 1 << 7;

  private static const BLEND_SHADER_CHANGED:uint = 1 << 8;
  private static const BLEND_MODE_CHANGED:uint = 1 << 9;

  /**
   * if component has been reparented, we need to potentially reassign systemManager, cause we could be in a new Window.
   */
  private static const SYSTEM_MANAGER_DIRTY:uint = 1 << 14;

  private static const HAS_FOCUSABLE_CHILDREN:uint = 1 << 15;
  private static const FOCUS_ENABLED:uint = 1 << 16;
  private static const MOUSE_FOCUS_ENABLED:uint = 1 << 17;
  private static const TAB_FOCUS_ENABLED:uint = 1 << 18;

  private var flags:uint = FOCUS_ENABLED | MOUSE_FOCUS_ENABLED;

  protected var _layoutMetrics:LayoutMetrics = EMPTY_LAYOUT_METRICS;
  public final function get layoutMetrics():LayoutMetrics {
    return _layoutMetrics;
  }

  public function set layoutMetrics(value:LayoutMetrics):void {
    _layoutMetrics = value;
    if (!isNaN(_layoutMetrics.width) && !_layoutMetrics.widthIsPercent) {
      _width = _layoutMetrics.width;
    }
    if (!isNaN(_layoutMetrics.height) && !_layoutMetrics.heightIsPercent) {
      _height = _layoutMetrics.height;
    }
  }

  /**
   * This method allows access to the Player's native implementation of addChildAt(), which can be useful
   * since components can override addChildAt() and thereby hide the native implementation.
   */
  public final function addDisplayObject(displayObject:DisplayObject, index:int = -1):void {
    super.addChildAt(displayObject, index == -1 ? numChildren : index);
  }

  public final function removeDisplayObject(child:DisplayObject):void {
    super.removeChild(child);
  }

  private static const DEFAULT_MAX_WIDTH:Number = 10000;
  private static const DEFAULT_MAX_HEIGHT:Number = 10000;

  public function AbstractView() {
    super();

    // Override  variables in superclasses.
    focusRect = false; // We do our own focus drawing.
    if (this is IFocusManagerComponent) {
      flags |= TAB_FOCUS_ENABLED;
      tabEnabled = true;
    }

    // Make the component invisible until the initialization sequence is complete.
    // It will be set visible when the 'initialized' flag is set.
    super.visible = false;

    _width = super.width;
    _height = super.height;
  }

  public function get initialized():Boolean {
    return (flags & INITIALIZED) != 0;
  }

  public function set initialized(value:Boolean):void {
    flags |= INITIALIZED;

    if (value) {
      setVisible(_visible, true);
      if (hasEventListener(FlexEvent.CREATION_COMPLETE)) {
        dispatchEvent(new FlexEvent(FlexEvent.CREATION_COMPLETE));
      }
    }
  }

  public function get processedDescriptors():Boolean {
    return (flags & PROCESSED_DESCRIPTORS) != 0;
  }

  public function set processedDescriptors(value:Boolean):void {
    if (value) {
      flags |= PROCESSED_DESCRIPTORS;
      if (hasEventListener(FlexEvent.INITIALIZE)) {
        dispatchEvent(new FlexEvent(FlexEvent.INITIALIZE));
      }
    }
    else {
      flags &= ~ PROCESSED_DESCRIPTORS;
    }
  }

  public function get updateCompletePendingFlag():Boolean {
    return (flags & UPDATE_COMPLETE_PENDING) != 0;
  }

  public function set updateCompletePendingFlag(value:Boolean):void {
    value ? flags |= UPDATE_COMPLETE_PENDING : flags &= ~UPDATE_COMPLETE_PENDING;
  }

  /**
   *  Holds the last recorded value of the width property.
   *  Used in dispatching a ResizeEvent.
   */
  private var oldWidth:Number = 0;

  /**
   *  Holds the last recorded value of the height property.
   *  Used in dispatching a ResizeEvent.
   */
  private var oldHeight:Number = 0;

  /**
   *  Holds the last recorded value of the minWidth property.
   */
  private var oldMinWidth:Number;

  /**
   *  Holds the last recorded value of the minHeight property.
   */
  private var oldMinHeight:Number;

  /**
   *  Holds the last recorded value of the explicitWidth property.
   */
  private var oldExplicitWidth:Number;

  /**
   *  Holds the last recorded value of the explicitHeight property.
   */
  private var oldExplicitHeight:Number;

  private var _owner:DisplayObjectContainer;
  public function get owner():DisplayObjectContainer {
    return _owner != null ? _owner : parent;
  }

  public function set owner(value:DisplayObjectContainer):void {
    _owner = value;
  }

  private var _width:Number;

  [Bindable("widthChanged")]
  [Inspectable(category="General")]
  [PercentProxy("percentWidth")]
  override public function get width():Number {
    return _width;
  }

  override public function set width(value:Number):void {
    if (_layoutMetrics.width != value) {
      explicitWidth = value;

      // We invalidate size because locking in width
      // may change the measured height in flow-based components.
      invalidateSize();
    }

    if (_width != value) {
      invalidateProperties();
      invalidateDisplayList();
      invalidateParentSizeAndDisplayList();

      _width = value;

      if (hasEventListener("widthChanged")) {
        dispatchEvent(new Event("widthChanged"));
      }
    }
  }

  private var _height:Number;

  /**
   *  Number that specifies the height of the component, in pixels,
   *  in the parent's coordinates.
   *  The default value is 0, but this property contains the actual component
   *  height after Flex completes sizing the components in your application.
   *
   *  <p>Note: You can specify a percentage value in the MXML
   *  <code>height</code> attribute, such as <code>height="100%"</code>,
   *  but you cannot use a percentage value for the <code>height</code>
   *  property in ActionScript;
   *  use the <code>percentHeight</code> property instead.</p>
   *
   *  <p>Setting this property causes a <code>resize</code> event to be dispatched.
   *  See the <code>resize</code> event for details on when
   *  this event is dispatched.</p>
   *
   *  @see #percentHeight
   */
  [PercentProxy("percentHeight")]
  override public function get height():Number {
    return _height;
  }

  override public function set height(value:Number):void {
    if (_layoutMetrics.height != value) {
      explicitHeight = value;

      // We invalidate size because locking in width
      // may change the measured height in flow-based components.
      invalidateSize();
    }

    if (_height != value) {
      invalidateProperties();
      invalidateDisplayList();
      invalidateParentSizeAndDisplayList();

      _height = value;

      if (hasEventListener("heightChanged")) {
        dispatchEvent(new Event("heightChanged"));
      }
    }
  }

  private var _visible:Boolean = true;

  [Bindable("hide")]
  [Bindable("show")]
  [Inspectable(category="General", defaultValue="true")]
  override public function get visible():Boolean {
    return _visible;
  }

  override public function set visible(value:Boolean):void {
    setVisible(value);
  }

  public function setVisible(value:Boolean, noEvent:Boolean = false):void {
    _visible = value;

    if (!initialized || super.visible == value) {
      return;
    }

    super.visible = value;

    if (!noEvent) {
      dispatchEvent(new FlexEvent(value ? FlexEvent.SHOW : FlexEvent.HIDE));
    }
  }

  [Inspectable(defaultValue="1.0", category="General", verbose="1", minValue="0.0", maxValue="1.0")]

  private var _blendMode:String = BlendMode.NORMAL;

  [Inspectable(category="General", enumeration="add,alpha,darken,difference,erase,hardlight,invert,layer,lighten,multiply,normal,subtract,screen,overlay,colordodge,colorburn,exclusion,softlight,hue,saturation,color,luminosity", defaultValue="normal")]
  override public function get blendMode():String {
    return _blendMode;
  }

  override public function set blendMode(value:String):void {
    if (_blendMode != value) {
      _blendMode = value;
      flags |= BLEND_MODE_CHANGED;

      // If one of the non-native Flash blendModes is set, record the new value and set the appropriate blendShader on the display object.
      if (value == "colordodge" || value == "colorburn" || value == "exclusion" || value == "softlight" || value == "hue" || value == "saturation" || value == "color" || value == "luminosity") {
        flags |= BLEND_SHADER_CHANGED;
      }
      invalidateProperties();
    }
  }

  /**
   *  Specifies whether the UIComponent object receives <code>doubleClick</code> events.
   *  The default value is <code>false</code>, which means that the UIComponent object
   *  does not receive <code>doubleClick</code> events.
   *
   *  <p>The <code>mouseEnabled</code> property must also be set to <code>true</code>,
   *  its default value, for the object to receive <code>doubleClick</code> events.</p>
   *
   *  @default false
   */
  override public function set doubleClickEnabled(value:Boolean):void {
    super.doubleClickEnabled = value;

    for (var i:int = 0; i < this.numChildren; i++) {
      var child:InteractiveObject = getChildAt(i) as InteractiveObject;
      if (child) {
        child.doubleClickEnabled = value;
      }
    }
  }

  public function get enabled():Boolean {
    return (flags & DISABLED) == 0;
  }

  public function set enabled(value:Boolean):void {
    if (value != ((flags & DISABLED) == 0)) {
      value ? flags &= ~DISABLED : flags |= DISABLED;
      invalidateDisplayList();
    }

    //dispatchEvent(new Event("enabledChanged"));
  }

  private var _filters:Array;

  override public function get filters():Array {
    return _filters ? _filters : super.filters;
  }

  override public function set filters(value:Array):void {
    var n:int;
    var i:int;
    var e:IEventDispatcher;

    if (_filters) {
      n = _filters.length;
      for (i = 0; i < n; i++) {
        e = _filters[i] as IEventDispatcher;
        if (e) {
          e.removeEventListener(BaseFilter.CHANGE, filterChangeHandler);
        }
      }
    }

    _filters = value;

    var clonedFilters:Array = [];
    if (_filters) {
      n = _filters.length;
      for (i = 0; i < n; i++) {
        if (_filters[i] is IBitmapFilter) {
          e = _filters[i] as IEventDispatcher;
          if (e) {
            e.addEventListener(BaseFilter.CHANGE, filterChangeHandler);
          }
          clonedFilters.push(IBitmapFilter(_filters[i]).clone());
        }
        else {
          clonedFilters.push(_filters[i]);
        }
      }
    }

    super.filters = clonedFilters;
  }

  public function get designLayer():DesignLayer {
    return null;
  }

  public function set designLayer(value:DesignLayer):void {
  }

  public function get tweeningProperties():Array {
    return null;
  }

  public function set tweeningProperties(value:Array):void {
  }

  private var _focusManager:IFocusManager;

  /**
   *  Gets the FocusManager that controls focus for this component
   *  and its peers.
   *  Each popup has its own focus loop and therefore its own instance
   *  of a FocusManager.
   *  To make sure you're talking to the right one, use this method.
   */
  public function get focusManager():IFocusManager {
    if (_focusManager) {
      return _focusManager;
    }

    var o:DisplayObject = parent;

    while (o) {
      if (o is IFocusManagerContainer) {
        return IFocusManagerContainer(o).focusManager;
      }

      o = o.parent;
    }

    return null;
  }

  /**
   * Set by the SystemManager so that each UIComponent has a references to its SystemManager
   */
  private var _systemManager:ISystemManager;

  public function get systemManager():ISystemManager {
    if (_systemManager == null || (flags & SYSTEM_MANAGER_DIRTY) != 0) {
      var r:DisplayObject = root;
      if (_systemManager != null && _systemManager.isProxy) {
        // keep the existing proxy
      }
      else if (r != null) {
        // If this object is attached to the display list, then the root property holds its SystemManager.
        // if the root is the Stage, then we are in a second AIR window
        _systemManager = ISystemManager(r is Stage ? Stage(r).getChildAt(0) : r);
      }
      else {
        // If this object isn't attached to the display list, then we need to walk up the parent chain ourselves.
        var o:DisplayObjectContainer = parent;
        while (o != null) {
          var ui:IUIComponent = o as IUIComponent;
          if (ui != null) {
            _systemManager = ui.systemManager;
            break;
          }
          else if (o is ISystemManager) {
            _systemManager = o as ISystemManager;
            break;
          }
          o = o.parent;
        }
      }
      flags &= ~SYSTEM_MANAGER_DIRTY;
    }

    return _systemManager;
  }

  public function set systemManager(value:ISystemManager):void {
    _systemManager = value;
    flags &= ~SYSTEM_MANAGER_DIRTY;
  }

  private var _nestLevel:int = 0;

  public function get nestLevel():int {
    return _nestLevel;
  }

  public function set nestLevel(value:int):void {
    // If my parent hasn't been attached to the display list, then its nestLevel
    // will be zero. If it tries to set my nestLevel to 1, ignore it.  We'll
    // update nest levels again after the parent is added to the display list.
    //
    // Also punt if the new value for nestLevel is the same as my current value.
    if (value > 1 && _nestLevel != value) {
      _nestLevel = value;

      updateCallbacks();

      var n:int = numChildren;
      for (var i:int = 0; i < n; i++) {
        var ui:ILayoutManagerClient = getChildAt(i) as ILayoutManagerClient;
        if (ui) {
          ui.nestLevel = value + 1;
        }
      }
    }
  }

  public function get document():Object {
    return null;
  }

  public function set document(value:Object):void {
  }

  private var _id:String;
  public function get id():String {
    return _id;
  }

  public function set id(value:String):void {
    _id = value;
  }

  private var _focusPane:Sprite;
  public function get focusPane():Sprite {
    return _focusPane;
  }

  public function set focusPane(value:Sprite):void {
    if (value) {
      addChild(value);

      value.x = 0;
      value.y = 0;
      value.scrollRect = null;

      _focusPane = value;
    }
    else {
      removeChild(_focusPane);

      _focusPane.mask = null;
      _focusPane = null;
    }
  }

  public function get focusEnabled():Boolean {
    return (flags & FOCUS_ENABLED) != 0;
  }

  public function set focusEnabled(value:Boolean):void {
    if (value == ((flags & FOCUS_ENABLED) == 0)) {
      value ? flags |= FOCUS_ENABLED : flags &= ~FOCUS_ENABLED;
    }
  }

  public function get hasFocusableChildren():Boolean {
    return (flags & HAS_FOCUSABLE_CHILDREN) != 0;
  }

  public function set hasFocusableChildren(value:Boolean):void {
    if (value == ((flags & HAS_FOCUSABLE_CHILDREN) == 0)) {
      value ? flags |= HAS_FOCUSABLE_CHILDREN : flags &= ~HAS_FOCUSABLE_CHILDREN;
    }
  }

  public function get mouseFocusEnabled():Boolean {
    return (flags & MOUSE_FOCUS_ENABLED) != 0;
  }

  protected function setMouseFocusEnabled(value:Boolean):void {
    if (value == ((flags & MOUSE_FOCUS_ENABLED) == 0)) {
      value ? flags |= MOUSE_FOCUS_ENABLED : flags &= ~MOUSE_FOCUS_ENABLED;
    }
  }

  public function get tabFocusEnabled():Boolean {
    return (flags & TAB_FOCUS_ENABLED) != 0;
  }

  protected function setTabFocusEnabled(value:Boolean):void {
    if (value == ((flags & TAB_FOCUS_ENABLED) == 0)) {
      value ? flags |= TAB_FOCUS_ENABLED : flags &= ~TAB_FOCUS_ENABLED;
    }
  }

  private var _measuredMinWidth:Number = 0;
  public final function get measuredMinWidth():Number {
    return _measuredMinWidth;
  }

  public function set measuredMinWidth(value:Number):void {
    _measuredMinWidth = value;
  }

  private var _measuredMinHeight:Number = 0;

  public function get measuredMinHeight():Number {
    return _measuredMinHeight;
  }

  public function set measuredMinHeight(value:Number):void {
    _measuredMinHeight = value;
  }

  private var _measuredWidth:Number = 0;

  public function get measuredWidth():Number {
    return _measuredWidth;
  }

  public function set measuredWidth(value:Number):void {
    _measuredWidth = value;
  }

  private var _measuredHeight:Number = 0;

  public function get measuredHeight():Number {
    return _measuredHeight;
  }

  public function set measuredHeight(value:Number):void {
    _measuredHeight = value;
  }

  public function get minWidth():Number {
    return isNaN(_layoutMetrics.minWidth) ? measuredMinWidth : _layoutMetrics.minWidth;
  }

  public function set minWidth(value:Number):void {
    if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
      _layoutMetrics = new LayoutMetrics();
    }
    else if (_layoutMetrics.minWidth == value) {
      return;
    }

    _layoutMetrics.minWidth = value;

    // We invalidate size because locking in width
    // may change the measured height in flow-based components.
    invalidateSize();
    invalidateParentSizeAndDisplayList();
  }

  public function get minHeight():Number {
    return isNaN(_layoutMetrics.minHeight) ? measuredMinHeight : _layoutMetrics.minHeight;
  }

  public function set minHeight(value:Number):void {
    if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
      _layoutMetrics = new LayoutMetrics();
    }
    else if (_layoutMetrics.minHeight == value) {
      return;
    }

    _layoutMetrics.minHeight = value;

    invalidateSize();
    invalidateParentSizeAndDisplayList();
  }

  public function get maxWidth():Number {
    return !isNaN(explicitMaxWidth) ? explicitMaxWidth : DEFAULT_MAX_WIDTH;
  }

  public function get maxHeight():Number {
    return !isNaN(explicitMaxHeight) ? explicitMaxHeight : DEFAULT_MAX_HEIGHT;
  }

  public final function get explicitMinWidth():Number {
    return _layoutMetrics.minWidth;
  }

  public function get explicitMinHeight():Number {
    return _layoutMetrics.minHeight;
  }

  public final function get explicitMaxWidth():Number {
    return _layoutMetrics.maxWidth;
  }

  public final function get explicitMaxHeight():Number {
    return _layoutMetrics.maxHeight;
  }

  public final function get explicitWidth():Number {
    return _layoutMetrics.widthIsPercent ? NaN : _layoutMetrics.width;
  }

  public function set explicitWidth(value:Number):void {
    if (_layoutMetrics.widthIsPercent) {
      _layoutMetrics.flags &= ~LayoutMetrics.PERCENT_WIDTH;
    }
    else if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
      _layoutMetrics = new LayoutMetrics();
    }
    else if (_layoutMetrics.width == value) {
      return;
    }

    _layoutMetrics.width = value;

    // We invalidate size because locking in width may change the measured height in flow-based components.
    invalidateSize();
    invalidateParentSizeAndDisplayList();
  }

  public final function get explicitHeight():Number {
    return _layoutMetrics.heightIsPercent ? NaN : _layoutMetrics.height;
  }

  public function set explicitHeight(value:Number):void {
    if (_layoutMetrics.heightIsPercent) {
      _layoutMetrics.flags &= ~LayoutMetrics.PERCENT_HEIGHT;
    }
    else if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
      _layoutMetrics = new LayoutMetrics();
    }
    else if (_layoutMetrics.height == value) {
      return;
    }

    _layoutMetrics.height = value;

    // We invalidate size because locking in height may change the measured width in flow-based components.
    invalidateSize();
    invalidateParentSizeAndDisplayList();
  }

  public function get percentWidth():Number {
    return _layoutMetrics.widthIsPercent ? _layoutMetrics.width : NaN;
  }

  public function set percentWidth(value:Number):void {
    if (!_layoutMetrics.widthIsPercent) {
      if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
        _layoutMetrics = new LayoutMetrics();
      }
      _layoutMetrics.flags |= LayoutMetrics.PERCENT_WIDTH;
    }
    else if (_layoutMetrics.width == value) {
      return;
    }

    _layoutMetrics.width = value;
    invalidateParentSizeAndDisplayList();
  }

  public function get percentHeight():Number {
    return _layoutMetrics.heightIsPercent ? _layoutMetrics.height : NaN;
  }

  public function set percentHeight(value:Number):void {
    if (!_layoutMetrics.heightIsPercent) {
      if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
        _layoutMetrics = new LayoutMetrics();
      }
      _layoutMetrics.flags |= LayoutMetrics.PERCENT_HEIGHT;
    }
    else if (_layoutMetrics.height == value) {
      return;
    }

    _layoutMetrics.height = value;
    invalidateParentSizeAndDisplayList();
  }

  [Bindable("includeInLayoutChanged")]
  public function get includeInLayout():Boolean {
    return (flags & EXCLUDE_FROM_LAYOUT) == 0;
  }

  public function set includeInLayout(value:Boolean):void {
    if (value != ((flags & EXCLUDE_FROM_LAYOUT) == 0)) {
      value ? flags &= ~EXCLUDE_FROM_LAYOUT : flags |= EXCLUDE_FROM_LAYOUT;

      var p:IInvalidating = parent as IInvalidating;
      if (p) {
        p.invalidateSize();
        p.invalidateDisplayList();
      }

      if (hasEventListener("includeInLayoutChanged")) {
        dispatchEvent(new Event("includeInLayoutChanged"));
      }
    }
  }

  public function get layoutDirection():String {
    return LAYOUT_DIRECTION_LTR;
  }

  public function set layoutDirection(value:String):void {
  }

  public function get baselinePosition():Number {
    throw new Error("abstract");
  }

  public function get isPopUp():Boolean {
    return false;
  }

  public function set isPopUp(value:Boolean):void {
  }

  override public function addChild(child:DisplayObject):DisplayObject {
    var formerParent:DisplayObjectContainer = child.parent;
    if (formerParent != null && !(formerParent is Loader)) {
      formerParent.removeChild(child);
    }

    addingChild(child);
    super.addChild(child);
    childAdded(child);

    return child;
  }

  override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
    var formerParent:DisplayObjectContainer = child.parent;
    if (formerParent && !(formerParent is Loader)) {
      formerParent.removeChild(child);
    }

    addingChild(child);
    super.addChildAt(child, index);
    childAdded(child);

    return child;
  }

  override public function removeChild(child:DisplayObject):DisplayObject {
    super.removeChild(child);
    childRemoved(child);
    return child;
  }

  override public function removeChildAt(index:int):DisplayObject {
    var child:DisplayObject = super.removeChildAt(index);
    childRemoved(child);
    return child;
  }

  /**
   * В Flex UIComponent он как mx_internal и используется в mx.states.RemoveChild
   */
  private function updateCallbacks():void {
    if (flags & INVALID_DISPLAY_LIST) {
      UIComponentGlobals.layoutManager.invalidateDisplayList(this);
    }

    if (flags & INVALID_SIZE) {
      UIComponentGlobals.layoutManager.invalidateSize(this);
    }

    if (flags & INVALID_PROPERTIES) {
      UIComponentGlobals.layoutManager.invalidateProperties(this);
    }

    // systemManager getter tries to set the internal _systemManager varaible if it is null. Hence a call to the getter is necessary.
    // Stage can be null when an untrusted application is loaded by an application that isn't on stage yet.
    if (systemManager != null && (_systemManager.stage != null)) {
      _systemManager.stage.invalidate();
    }
  }

  public function parentChanged(p:DisplayObjectContainer):void {
    if (p == null) {
      _nestLevel = 0;
    }
  }

  private function addingChild(child:DisplayObject):void {
    // Set the nestLevel of the child to be one greater than the nestLevel of this component.
    // The nestLevel setter will recursively set it on any descendants of the child that exist.
    if (child is ILayoutManagerClient) {
      ILayoutManagerClient(child).nestLevel = nestLevel + 1;
    }

    if (child is InteractiveObject && doubleClickEnabled) {
      InteractiveObject(child).doubleClickEnabled = true;
    }

    if (child is UIComponent) {
      UIComponent(child).stylesInitialized();
    }
  }

  private static function childAdded(child:DisplayObject):void {
    if (child is UIComponent && !UIComponent(child).initialized) {
      UIComponent(child).initialize();
    }
    else if (child is View && !View(child).initialized) {
      View(child).initialize();
    }
    else if (child is IUIComponent) {
      IUIComponent(child).initialize();
    }
  }

  private static function childRemoved(child:DisplayObject):void {
    if (child is IUIComponent) {
      IUIComponent(child).parentChanged(null);
    }
  }

  public function initialize():void {
    if (initialized) {
      return;
    }

    // The "preinitialize" event gets dispatched after everything about this
    // DisplayObject has been initialized, and it has been attached to its parent, but before any of its children have been created.
    // This allows a "preinitialize" event handler to set properties which affect child creation.
    // Note that this implies that "preinitialize" handlers are called top-down; i.e., parents before children.
    if (hasEventListener(FlexEvent.PREINITIALIZE)) {
      dispatchEvent(new FlexEvent(FlexEvent.PREINITIALIZE));
    }

    createChildren();

    invalidateProperties();
    invalidateSize();
    invalidateDisplayList();

    processedDescriptors = true;
  }

  /**
   *  Create child objects of the component.
   *  This is an advanced method that you might override
   *  when creating a subclass of UIComponent.
   *
   *  <p>A component that creates other components or objects within it is called a composite component.
   *  For example, the Flex ComboBox control is actually made up of a TextInput control
   *  to define the text area of the ComboBox, and a Button control to define the ComboBox arrow.
   *  Components implement the <code>createChildren()</code> method to create child
   *  objects (such as other components) within the component.</p>
   *
   *  <p>From within an override of the <code>createChildren()</code> method,
   *  you call the <code>addChild()</code> method to add each child object. </p>
   *
   *  <p>You do not call this method directly. Flex calls the
   *  <code>createChildren()</code> method in response to the call to
   *  the <code>addChild()</code> method to add the component to its parent. </p>
   */
  protected function createChildren():void {
  }

  public final function invalidateProperties():void {
    if ((flags & INVALID_PROPERTIES) == 0) {
      flags |= INVALID_PROPERTIES;

      if (parent != null) {
        UIComponentGlobals.layoutManager.invalidateProperties(this);
      }
    }
  }

  public final function invalidateSize():void {
    if ((flags & INVALID_SIZE) == 0) {
      flags |= INVALID_SIZE;

      if (parent != null) {
        UIComponentGlobals.layoutManager.invalidateSize(this);
      }
    }
  }

  /**
   *  Helper method to invalidate parent size and display list if
   *  this object affects its layout (includeInLayout is true).
   *
   *  @langversion 3.0
   *  @playerversion Flash 9
   *  @playerversion AIR 1.1
   *  @productversion Flex 3
   */
  protected function invalidateParentSizeAndDisplayList():void {
    if (!includeInLayout) {
      return;
    }

    var p:IInvalidating = parent as IInvalidating;
    if (!p) {
      return;
    }

    p.invalidateSize();
    p.invalidateDisplayList();
  }

  protected final function get displayListInvalid():Boolean {
    return (flags & INVALID_DISPLAY_LIST) != 0;
  }

  public final function invalidateDisplayList():void {
    if ((flags & INVALID_DISPLAY_LIST) == 0) {
      flags |= INVALID_DISPLAY_LIST;

      if (parent != null) {
        UIComponentGlobals.layoutManager.invalidateDisplayList(this);
      }
    }
  }

  public function invalidateLayoutDirection():void {
    // develar: removed children validation, we don't support layout direction
  }

  public function validateNow():void {
    UIComponentGlobals.layoutManager.validateClient(this);
  }

  public function validateProperties():void {
    if (flags & INVALID_PROPERTIES) {
      commitProperties();
      flags &= ~INVALID_PROPERTIES;
    }
  }

  /**
   *  Processes the properties set on the component.
   *  This is an advanced method that you might override
   *  when creating a subclass of UIComponent.
   *
   *  <p>You do not call this method directly.
   *  Flex calls the <code>commitProperties()</code> method when you
   *  use the <code>addChild()</code> method to add a component to a container,
   *  or when you call the <code>invalidateProperties()</code> method of the component.
   *  Calls to the <code>commitProperties()</code> method occur before calls to the
   *  <code>measure()</code> method. This lets you set property values that might
   *  be used by the <code>measure()</code> method.</p>
   *
   *  <p>Some components have properties that affect the number or kinds
   *  of child objects that they need to create, or have properties that
   *  interact with each other, such as the <code>horizontalScrollPolicy</code>
   *  and <code>horizontalScrollPosition</code> properties.
   *  It is often best at startup time to process all of these
   *  properties at one time to avoid duplicating work.</p>
   *
   *  @langversion 3.0
   *  @playerversion Flash 9
   *  @playerversion AIR 1.1
   *  @productversion Flex 3
   */
  protected function commitProperties():void {
    if (width != oldWidth || height != oldHeight) {
      dispatchResizeEvent();
    }

    if (flags & BLEND_MODE_CHANGED) {
      flags &= ~BLEND_MODE_CHANGED;

      if ((flags & BLEND_SHADER_CHANGED) == 0) {
        super.blendMode = _blendMode;
      }
      else {
        // The graphic element's blendMode was set to a non-Flash
        // blendMode. We mimic the look by instantiating the
        // appropriate shader class and setting the blendShader
        // property on the displayObject.
        flags &= ~BLEND_SHADER_CHANGED;

        super.blendMode = BlendMode.NORMAL;

        switch (_blendMode) {
          case "color":
            super.blendShader = new ColorShader();
            break;

          case "colordodge":
            super.blendShader = new ColorDodgeShader();
            break;

          case "colorburn":
            super.blendShader = new ColorBurnShader();
            break;

          case "exclusion":
            super.blendShader = new ExclusionShader();
            break;

          case "hue":
            super.blendShader = new HueShader();
            break;

          case "luminosity":
            super.blendShader = new LuminosityShader();
            break;

          case "saturation":
            super.blendShader = new SaturationShader();
            break;

          case "softlight":
            super.blendShader = new SoftLightShader();
            break;
        }
      }
    }
  }

  public function validateSize(recursive:Boolean = false):void {
    if (recursive) {
      var child:ILayoutManagerClient;
      for (var i:int = 0, n:int = numChildren; i < n; i++) {
        if ((child = getChildAt(i) as ILayoutManagerClient) != null) {
          child.validateSize(true);
        }
      }
    }

    if ((flags & INVALID_SIZE) != 0 && includeInLayout && measureSizes()) {
      invalidateDisplayList();
      invalidateParentSizeAndDisplayList();
    }
  }

  /**
   * @return 0 nothing 1 min 2 max
   */
  protected final function adjustMeasuredWidthToRange():int {
    if (_measuredWidth < explicitMinWidth) {
      _measuredWidth = explicitMinWidth;
      return 1;
    }
    else if (_measuredWidth > explicitMaxWidth) {
      _measuredWidth = explicitMaxWidth;
      return 2;
    }

    return 0;
  }

  protected final function adjustMeasuredHeightToRange():int {
    if (_measuredHeight < explicitMinHeight) {
      _measuredHeight = explicitMinHeight;
      return 1;
    }
    else if (measuredHeight > explicitMaxHeight) {
      _measuredHeight = explicitMaxHeight;
      return 2;
    }

    return 0;
  }

  /**
   *  Determines if the call to the <code>measure()</code> method can be skipped.
   *
   *  @return Returns <code>true</code> when the <code>measureSizes()</code> method can skip the call to
   *  the <code>measure()</code> method. For example this is usually <code>true</code> when both <code>explicitWidth</code> and
   *  <code>explicitHeight</code> are set.
   */
  protected function canSkipMeasurement():Boolean {
    return !isNaN(_layoutMetrics.width) && !isNaN(_layoutMetrics.height) && !_layoutMetrics.widthIsPercent && !_layoutMetrics.heightIsPercent;
  }

  private function measureSizes():Boolean {
    flags &= ~INVALID_SIZE;
    if (canSkipMeasurement()) {

      // develar — закомментировано — если мы установили ширину явно, то почему мы должны сбрасывать _measuredMinWidth/_measuredMinHeight — см. WindowResizer
      //			_measuredMinWidth = 0;
      //			_measuredMinHeight = 0;
    }
    else {
      measure();
      adjustMeasuredWidthToRange();
      adjustMeasuredHeightToRange();
    }

    if (isNaN(oldMinWidth)) {
      // This branch does the same thing as the else branch, but it is optimized for the first time that
      // measureSizes() is called on this object.
      oldMinWidth = _layoutMetrics.minWidth == _layoutMetrics.minWidth ? _layoutMetrics.minWidth : measuredMinWidth;
      oldMinHeight = _layoutMetrics.minHeight == _layoutMetrics.minHeight ? _layoutMetrics.minHeight : measuredMinHeight;
      oldExplicitWidth = _layoutMetrics.width == _layoutMetrics.width && !_layoutMetrics.widthIsPercent ? _layoutMetrics.width : measuredWidth;
      oldExplicitHeight = _layoutMetrics.height == _layoutMetrics.height && !_layoutMetrics.heightIsPercent ? _layoutMetrics.height : measuredHeight;

      return true;
    }
    else {
      var newValue:Number = _layoutMetrics.minWidth == _layoutMetrics.minWidth ? _layoutMetrics.minWidth : measuredMinWidth;
      if (newValue != oldMinWidth) {
        oldMinWidth = newValue;
        return true;
      }

      newValue = _layoutMetrics.minHeight == _layoutMetrics.minHeight ? _layoutMetrics.minHeight : measuredMinHeight;
      if (newValue != oldMinHeight) {
        oldMinHeight = newValue;
        return true;
      }

      newValue = _layoutMetrics.width == _layoutMetrics.width && !_layoutMetrics.widthIsPercent ? _layoutMetrics.width : measuredWidth;
      if (newValue != oldExplicitWidth) {
        oldExplicitWidth = newValue;
        return true;
      }

      newValue = _layoutMetrics.height == _layoutMetrics.height && !_layoutMetrics.heightIsPercent ? _layoutMetrics.height : measuredHeight;
      if (newValue != oldExplicitHeight) {
        oldExplicitHeight = newValue;
        return true;
      }

      return false;
    }
  }

  /**
   *  Calculates the default size, and optionally the default minimum size,
   *  of the component. This is an advanced method that you might override when
   *  creating a subclass of UIComponent.
   *
   *  <p>You do not call this method directly. Flex calls the
   *  <code>measure()</code> method when the component is added to a container
   *  using the <code>addChild()</code> method, and when the component's
   *  <code>invalidateSize()</code> method is called. </p>
   *
   *  <p>When you set a specific height and width of a component,
   *  Flex does not call the <code>measure()</code> method,
   *  even if you explicitly call the <code>invalidateSize()</code> method.
   *  That is, Flex only calls the <code>measure()</code> method if
   *  the <code>explicitWidth</code> property or the <code>explicitHeight</code>
   *  property of the component is NaN. </p>
   *
   *  <p>In your override of this method, you must set the
   *  <code>measuredWidth</code> and <code>measuredHeight</code> properties
   *  to define the default size.
   *  You can optionally set the <code>measuredMinWidth</code> and
   *  <code>measuredMinHeight</code> properties to define the default
   *  minimum size.</p>
   *
   *  <p>Most components calculate these values based on the content they are
   *  displaying, and from the properties that affect content display.
   *  A few components simply have hard-coded default values. </p>
   *
   *  <p>The conceptual point of <code>measure()</code> is for the component to provide
   *  its own natural or intrinsic size as a default. Therefore, the
   *  <code>measuredWidth</code> and <code>measuredHeight</code> properties
   *  should be determined by factors such as:</p>
   *  <ul>
   *   <li>The amount of text the component needs to display.</li>
   *   <li>The styles, such as <code>fontSize</code>, for that text.</li>
   *   <li>The size of a JPEG image that the component displays.</li>
   *   <li>The measured or explicit sizes of the component's children.</li>
   *   <li>Any borders, margins, and gaps.</li>
   *  </ul>
   *
   *  <p>In some cases, there is no intrinsic way to determine default values.
   *  For example, a simple GreenCircle component might simply set
   *  measuredWidth = 100 and measuredHeight = 100 in its <code>measure()</code> method to
   *  provide a reasonable default size. In other cases, such as a TextArea,
   *  an appropriate computation (such as finding the right width and height
   *  that would just display all the text and have the aspect ratio of a Golden Rectangle)
   *  might be too time-consuming to be worthwhile.</p>
   *
   *  <p>The default implementation of <code>measure()</code>
   *  sets <code>measuredWidth</code>, <code>measuredHeight</code>,
   *  <code>measuredMinWidth</code>, and <code>measuredMinHeight</code>
   *  to <code>0</code>.</p>
   */
  protected function measure():void {
    measuredMinWidth = 0;
    measuredMinHeight = 0;
    measuredWidth = 0;
    measuredHeight = 0;
  }

  public function getExplicitOrMeasuredWidth():Number {
    return !isNaN(_layoutMetrics.width) ? _layoutMetrics.width : measuredWidth;
  }

  public function getExplicitOrMeasuredHeight():Number {
    return !isNaN(_layoutMetrics.height) ? _layoutMetrics.height : measuredHeight;
  }

  public function validateDisplayList():void {
    if (flags & INVALID_DISPLAY_LIST) {
      // Check if our parent is the top level system manager
      var sm:ISystemManager = parent as ISystemManager;
      if (sm != null && (sm.isProxy || (sm == systemManager.topLevelSystemManager && sm.document != this))) {
        // Size ourself to the new measured width/height This can cause the _layoutFeatures computed matrix to become invalid
        setActualSize(getExplicitOrMeasuredWidth(), getExplicitOrMeasuredHeight());
      }

      updateDisplayList(width, height);

      flags &= ~INVALID_DISPLAY_LIST;
    }
  }

  /**
   *  Draws the object and/or sizes and positions its children.
   *  This is an advanced method that you might override
   *  when creating a subclass of UIComponent.
   *
   *  <p>You do not call this method directly. Flex calls the
   *  <code>updateDisplayList()</code> method when the component is added to a container
   *  using the <code>addChild()</code> method, and when the component's
   *  <code>invalidateDisplayList()</code> method is called. </p>
   *
   *  <p>If the component has no children, this method
   *  is where you would do programmatic drawing
   *  using methods on the component's Graphics object
   *  such as <code>graphics.drawRect()</code>.</p>
   *
   *  <p>If the component has children, this method is where
   *  you would call the <code>move()</code> and <code>setActualSize()</code>
   *  methods on its children.</p>
   *
   *  <p>Components can do programmatic drawing even if
   *  they have children. In doing either, use the
   *  component's <code>unscaledWidth</code> and <code>unscaledHeight</code>
   *  as its bounds.</p>
   *
   *  <p>It is important to use <code>unscaledWidth</code> and
   *  <code>unscaledHeight</code> instead of the <code>width</code>
   *  and <code>height</code> properties.</p>
   *
   *  @param w Specifies the width of the component, in pixels,
   *  in the component's coordinates, regardless of the value of the
   *  <code>scaleX</code> property of the component.
   *
   *  @param h Specifies the height of the component, in pixels,
   *  in the component's coordinates, regardless of the value of the
   *  <code>scaleY</code> property of the component.
   *
   *  @langversion 3.0
   *  @playerversion Flash 9
   *  @playerversion AIR 1.1
   *  @productversion Flex 3
   */
  protected function updateDisplayList(w:Number, h:Number):void {
  }

  public function get left():Object {
    return _layoutMetrics.left;
  }

  public function set left(value:Object):void {
    if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
      _layoutMetrics = new LayoutMetrics();
    }
    else if (_layoutMetrics.left == value) {
      return;
    }

    _layoutMetrics.left = Number(value);
    invalidateSize();
    invalidateParentSizeAndDisplayList();
    invalidateDisplayList();
  }

  public function get right():Object {
    return _layoutMetrics.right;
  }

  public function set right(value:Object):void {
    if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
      _layoutMetrics = new LayoutMetrics();
    }
    else if (_layoutMetrics.right == value) {
      return;
    }

    _layoutMetrics.right = Number(value);
    invalidateSize();
    invalidateParentSizeAndDisplayList();
    invalidateDisplayList();
  }

  public function get top():Object {
    return _layoutMetrics.top;
  }

  public function set top(value:Object):void {
    if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
      _layoutMetrics = new LayoutMetrics();
    }
    _layoutMetrics.top = Number(value);
  }

  public function get bottom():Object {
    return _layoutMetrics.bottom;
  }

  public function set bottom(value:Object):void {
    if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
      _layoutMetrics = new LayoutMetrics();
    }
    _layoutMetrics.bottom = Number(value);
  }

  public function get horizontalCenter():Object {
    return _layoutMetrics.horizontalCenter;
  }

  public function set horizontalCenter(value:Object):void {
    if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
      _layoutMetrics = new LayoutMetrics();
    }
    _layoutMetrics.horizontalCenter = Number(value);
  }

  public function get verticalCenter():Object {
    return _layoutMetrics.verticalCenter;
  }

  public function set verticalCenter(value:Object):void {
    if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
      _layoutMetrics = new LayoutMetrics();
    }
    _layoutMetrics.verticalCenter = Number(value);
  }

  public function get baseline():Object {
    return _layoutMetrics.baseline;
  }

  public function set baseline(value:Object):void {
    if (_layoutMetrics == EMPTY_LAYOUT_METRICS) {
      _layoutMetrics = new LayoutMetrics();
    }
    _layoutMetrics.baseline = Number(value);
  }

  public function move(x:Number, y:Number):void {
    var changed:Boolean = false;

    if (x != this.x) {
        super.x = x;

      if (hasEventListener("xChanged")) {
        dispatchEvent(new Event("xChanged"));
      }
      changed = true;
    }

    if (y != this.y) {
        super.y = y;

      if (hasEventListener("yChanged")) {
        dispatchEvent(new Event("yChanged"));
      }
      changed = true;
    }

    if (changed) {
      if (hasEventListener(MoveEvent.MOVE)) {
        dispatchEvent(new MoveEvent(MoveEvent.MOVE));
      }
    }
  }

  public function setActualSize(w:Number, h:Number):void {
    var changed:Boolean = false;
    if (_width != w) {
      _width = w;
      changed = true;
    }

    if (_height != h) {
      _height = h;
      changed = true;
    }

    if (changed) {
      invalidateDisplayList();
      dispatchResizeEvent();
    }
  }

  /**
   *  Gets the object that currently has focus.
   *  It might not be this object.
   *  Note that this method does not necessarily return the component
   *  that has focus.
   *  It can return the internal subcomponent of the component
   *  that has focus.
   *  To get the component that has focus, use the
   *  <code>focusManager.focus</code> property.
   *
   *  @return Object that has focus.
   *
   *  @langversion 3.0
   *  @playerversion Flash 9
   *  @playerversion AIR 1.1
   *  @productversion Flex 3
   */
  public function getFocus():InteractiveObject {
    var sm:ISystemManager = systemManager;
    if (sm == null) {
      return null;
    }

    if (UIComponentGlobals.nextFocusObject) {
      return UIComponentGlobals.nextFocusObject;
    }

    if (sm.stage != null) {
      return sm.stage.focus;
    }

    return null;
  }

  public function setFocus():void {
    var sm:ISystemManager = systemManager;
    if (sm && (sm.stage)) {
      if (UIComponentGlobals.callLaterDispatcherCount == 0) {
        sm.stage.focus = this;
        UIComponentGlobals.nextFocusObject = null;
      }
      else {
        UIComponentGlobals.nextFocusObject = this;
        sm.addEventListener(FlexEvent.ENTER_FRAME, setFocusLater);
      }
    }
    else {
      UIComponentGlobals.nextFocusObject = this;
      //callLater(setFocusLater);
    }
  }

  protected final function dispatchPropertyChangeEvent(prop:String, oldValue:*, value:*):void {
    if (hasEventListener("propertyChange")) {
      dispatchEvent(PropertyChangeEvent.createUpdateEvent(this, prop, oldValue, value));
    }
  }

  private function dispatchResizeEvent():void {
    if (hasEventListener(ResizeEvent.RESIZE)) {
      dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE, false, false, oldWidth, oldHeight));
    }

    oldWidth = width;
    oldHeight = height;
  }

  /**
   *  Typically overridden by components containing UITextField objects,
   *  where the UITextField object gets focus.
   *
   *  @param target A UIComponent object containing a UITextField object
   *  that can receive focus.
   *
   *  @return Returns <code>true</code> if the UITextField object has focus.
   */
  protected function isOurFocus(target:DisplayObject):Boolean {
    return target == this;
  }

  /**
   *  The event handler called when a UIComponent object gets focus.
   *  If you override this method, make sure to call the base class version.
   */
  protected function focusInHandler(event:FocusEvent):void {
    if (isOurFocus(DisplayObject(event.target))) {
      var fm:IFocusManager = focusManager;
      if (fm && fm.showFocusIndicator) {
        //				drawFocus(true);
      }
    }
  }

  /**
   *  The event handler called when a UIComponent object loses focus.
   *  If you override this method, make sure to call the base class version.
   *
   *  @param event The event object.
   */
  protected function focusOutHandler(event:FocusEvent):void {
    // We don't need to remove our event listeners here because we
    // won't receive keyboard events.
    if (isOurFocus(DisplayObject(event.target))) {
      //			drawFocus(false);
    }
  }

  /**
   *  There is a bug (139390) where setting focus from within callLaterDispatcher
   *  screws up the ActiveX player.  We defer focus until enterframe.
   */
  private function setFocusLater(event:Event = null):void {
    var sm:ISystemManager = systemManager;
    if (sm && sm.stage) {
      sm.stage.removeEventListener(Event.ENTER_FRAME, setFocusLater);
      if (UIComponentGlobals.nextFocusObject) {
        sm.stage.focus = UIComponentGlobals.nextFocusObject;
      }
      UIComponentGlobals.nextFocusObject = null;
    }
  }

  private function filterChangeHandler(event:Event):void {
    filters = _filters;
  }

  public function owns(child:DisplayObject):Boolean {
    if (contains(child)) {
      return true;
    }

    try {
      while (child && child != this) {
        // do a parent walk
        if (child is IUIComponent) {
          child = IUIComponent(child).owner;
        }
        else {
          child = child.parent;
        }
      }
    }
    catch (e:SecurityError) {
      // You can't own what you don't have access to.
      return false;
    }

    return child == this;
  }

  public function get postLayoutTransformOffsets():TransformOffsets {
    return null;
  }

  public function set postLayoutTransformOffsets(value:TransformOffsets):void {
  }

  public function setLayoutMatrix(value:Matrix, invalidateLayout:Boolean):void {
    throw new IllegalOperationError();
  }

  public function setLayoutMatrix3D(value:Matrix3D, invalidateLayout:Boolean):void {
    throw new IllegalOperationError();
  }

  public function transformAround(transformCenter:Vector3D, scale:Vector3D = null, rotation:Vector3D = null, translation:Vector3D = null, postLayoutScale:Vector3D = null, postLayoutRotation:Vector3D = null, postLayoutTranslation:Vector3D = null, invalidateLayout:Boolean = true):void {
    throw new IllegalOperationError("unsupported method");
  }

  public function get depth():Number {
    return 0;
  }

  public function set depth(value:Number):void {
    throw new IllegalOperationError("unsupported property");
  }

  public function getPreferredBoundsWidth(postLayoutTransform:Boolean = true):Number {
    return LayoutElementUIComponentUtils.getPreferredBoundsWidth(this, null);
  }

  public function getPreferredBoundsHeight(postLayoutTransform:Boolean = true):Number {
    return LayoutElementUIComponentUtils.getPreferredBoundsHeight(this, null);
  }

  public function getMinBoundsWidth(postLayoutTransform:Boolean = true):Number {
    return LayoutElementUIComponentUtils.getMinBoundsWidth(this, null);
  }

  public function getMinBoundsHeight(postLayoutTransform:Boolean = true):Number {
    return LayoutElementUIComponentUtils.getMinBoundsHeight(this, null);
  }

  public function getMaxBoundsWidth(postLayoutTransform:Boolean = true):Number {
    return LayoutElementUIComponentUtils.getMaxBoundsWidth(this, null);
  }

  public function getMaxBoundsHeight(postLayoutTransform:Boolean = true):Number {
    return LayoutElementUIComponentUtils.getMaxBoundsHeight(this, null);
  }

  public function getBoundsXAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number {
    return LayoutElementUIComponentUtils.getBoundsXAtSize(this, width, height, null);
  }

  public function getBoundsYAtSize(width:Number, height:Number, postLayoutTransform:Boolean = true):Number {
    return LayoutElementUIComponentUtils.getBoundsYAtSize(this, width, height, null);
  }

  public function getLayoutBoundsWidth(postLayoutTransform:Boolean = true):Number {
    return LayoutElementUIComponentUtils.getLayoutBoundsWidth(this, null);
  }

  public function getLayoutBoundsHeight(postLayoutTransform:Boolean = true):Number {
    return LayoutElementUIComponentUtils.getLayoutBoundsHeight(this, null);
  }

  public function getLayoutBoundsX(postLayoutTransform:Boolean = true):Number {
    return LayoutElementUIComponentUtils.getLayoutBoundsX(this, null);
  }

  public function getLayoutBoundsY(postLayoutTransform:Boolean = true):Number {
    return LayoutElementUIComponentUtils.getLayoutBoundsY(this, null);
  }

  public function setLayoutBoundsPosition(x:Number, y:Number, postLayoutTransform:Boolean = true):void {
    LayoutElementUIComponentUtils.setLayoutBoundsPosition(this, x, y, null);
  }

  public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean = true):void {
    LayoutElementUIComponentUtils.setLayoutBoundsSize(this, width, height, null);
  }

  public function getLayoutMatrix():Matrix {
    return super.transform.matrix;
  }

  public function get hasLayoutMatrix3D():Boolean {
    return false;
  }

  public function get is3D():Boolean {
    return false;
  }

  public function getLayoutMatrix3D():Matrix3D {
    throw new IllegalOperationError();
  }
}
}