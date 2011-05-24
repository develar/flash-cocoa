package cocoa {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.errors.IllegalOperationError;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.ApplicationDomain;
import flash.text.TextFormat;
import flash.utils.Dictionary;

import mx.core.IChildList;
import mx.core.IFlexDisplayObject;
import mx.core.IFlexModule;
import mx.core.IUIComponent;
import mx.core.RSLData;
import mx.core.Singleton;
import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.managers.ILayoutManagerClient;
import mx.managers.ISystemManager;
import mx.managers.PopUpManagerImpl;
import mx.managers.systemClasses.ActiveWindowManager;

use namespace mx_internal;

public class WindowedSystemManager extends Sprite implements ISystemManager {
  // offset due: 0 child of system manager is application
  public static const OFFSET:int = 0;

  private var contentView:DisplayObject;

  override public function get width():Number {
    return stage.stageWidth;
  }

  override public function get height():Number {
    return stage.stageHeight;
  }

  public function init(contentView:IUIComponent):void {
    Singleton.registerClass("mx.managers::IPopUpManager", PopUpManagerImpl);
    registerImplementation("mx.managers::IActiveWindowManager", new ActiveWindowManager(this));

    if (contentView != null) {
      IFlexDisplayObject(contentView).setActualSize(stage.stageWidth, stage.stageHeight);
      this.contentView = DisplayObject(contentView);
      addRawChildAt(this.contentView, 0);
    }
  }

  private var _toolTipChildren:SystemChildList;
  public function get toolTipChildren():IChildList {
    if (_toolTipChildren == null) {
      _toolTipChildren = new SystemChildList(this, "topMostIndex", "toolTipIndex");
    }

    return _toolTipChildren;
  }

  private var _popUpChildren:SystemChildList;
  public function get popUpChildren():IChildList {
    if (_popUpChildren == null) {
      _popUpChildren = new SystemChildList(this, "noTopMostIndex", "topMostIndex");
    }

    return _popUpChildren;
  }

  public function get cursorChildren():IChildList {
    throw new IllegalOperationError();
  }

  override public function setChildIndex(child:DisplayObject, index:int):void {
    super.setChildIndex(child, OFFSET + index);
  }

  override public function getChildIndex(child:DisplayObject):int {
    return super.getChildIndex(child) - OFFSET;
  }

  override public function addChild(child:DisplayObject):DisplayObject {
    var addIndex:int = numChildren;
    if (child.parent == this) {
      addIndex--;
    }

    return addChildAt(child, addIndex);
  }

  override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
    noTopMostIndex++;

    var oldParent:DisplayObjectContainer = child.parent;
    if (oldParent) {
      oldParent.removeChild(child);
    }

    return addRawChildAt(child, index + OFFSET);
  }

  override public function getObjectsUnderPoint(point:Point):Array {
    var children:Array = [];
    // Get all the children that aren't tooltips
    var n:int = _topMostIndex;
    for (var i:int = 0; i < n; i++) {
      var child:DisplayObject = super.getChildAt(i);
      if (child is DisplayObjectContainer) {
        var temp:Array = DisplayObjectContainer(child).getObjectsUnderPoint(point);
        if (temp != null) {
          children = children.concat(temp);
        }
      }
    }

    return children;
  }

  public function $getObjectsUnderPoint(point:Point):Array {
    return super.getObjectsUnderPoint(point);
  }

  override public function contains(child:DisplayObject):Boolean {
    if (super.contains(child)) {
      if (child.parent == this) {
        var childIndex:int = super.getChildIndex(child);
        if (childIndex < _noTopMostIndex) {
          return true;
        }
      }
      else {
        for (var i:int = 0; i < _noTopMostIndex; i++) {
          var myChild:DisplayObject = super.getChildAt(i);
          if (myChild is DisplayObjectContainer && DisplayObjectContainer(myChild).contains(child)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  public function $contains(child:DisplayObject):Boolean {
    return super.contains(child);
  }

  private var _toolTipIndex:int = 0;
  public function get toolTipIndex():int {
    return _toolTipIndex;
  }

  public function set toolTipIndex(value:int):void {
    _toolTipIndex = value;
  }

  private var _topMostIndex:int;
  public function get topMostIndex():int {
    return _topMostIndex;
  }

  public function set topMostIndex(value:int):void {
    var delta:int = value - _topMostIndex;
    _topMostIndex = value;
    toolTipIndex += delta;
  }

  private var _noTopMostIndex:int = OFFSET; // fucked flex sdk preloader set it as 1 for mouse catcher (missed in our case) and 2 as app (we add app directly)
  public function get noTopMostIndex():int {
    return _noTopMostIndex;
  }

  //noinspection JSUnusedGlobalSymbols
  public function set noTopMostIndex(value:int):void {
    var delta:int = value - _noTopMostIndex;
    _noTopMostIndex = value;
    topMostIndex += delta;
  }

  override public function get numChildren():int {
    return noTopMostIndex - OFFSET;
  }

  public function addRawChildAt(child:DisplayObject, index:int):DisplayObject {
    addingChild(child);
    super.addChildAt(child, index);

    if (child.hasEventListener(FlexEvent.ADD)) {
      child.dispatchEvent(new FlexEvent(FlexEvent.ADD));
    }

    if (child is IUIComponent) {
      IUIComponent(child).initialize();
    }

    return child;
  }

  override public function removeChild(child:DisplayObject):DisplayObject {
    _noTopMostIndex--;
    return removeRawChild(child);
  }

  override public function removeChildAt(index:int):DisplayObject {
    noTopMostIndex--;
    return removeRawChildAt(index + OFFSET);
  }

  public function removeRawChild(child:DisplayObject):DisplayObject {
    if (child.hasEventListener(FlexEvent.REMOVE)) {
      child.dispatchEvent(new FlexEvent(FlexEvent.REMOVE));
    }

    super.removeChild(child);

    if (child is IUIComponent) {
      IUIComponent(child).parentChanged(null);
    }

    return child;
  }

  public function removeRawChildAt(index:int):DisplayObject {
    return removeRawChild(super.getChildAt(index));
  }

  public function getRawChildAt(index:int):DisplayObject {
    return super.getChildAt(index);
  }

  public function addingChild(object:DisplayObject):void {
    if (object is IUIComponent) {
      IUIComponent(object).systemManager = this;
    }

    if (object is ILayoutManagerClient) {
      ILayoutManagerClient(object).nestLevel = 2;
    }

    if (object is IUIComponent) {
      IUIComponent(object).parentChanged(this);
    }
	}

  public function get preloadedRSLs():Dictionary {
    return null;
  }

  public function allowDomain(... rest):void {
  }

  public function callInContext(fn:Function, thisArg:Object, argArray:Array, returns:Boolean = true):* {
    return null;
  }

  public function create(... params):Object {
    var mainClassName:String = String(params[0]);
    var mainClass:Class;
    var domain:ApplicationDomain = ApplicationDomain.currentDomain;
    if (domain.hasDefinition(mainClassName)) {
      mainClass = Class(domain.getDefinition(mainClassName));
    }
    else {
      throw new Error("Class '" + mainClassName + "' not found.");
    }

    var instance:Object = new mainClass();
    if (instance is IFlexModule) {
      IFlexModule(instance).moduleFactory = this;
    }
    return instance;
  }

  private const implementations:Dictionary = new Dictionary();
  public function getImplementation(interfaceName:String):Object {
    return implementations[interfaceName];
  }

  public function info():Object {
    return null;
  }

  public function registerImplementation(interfaceName:String, impl:Object):void {
    implementations[interfaceName] = impl;
  }

  public function get embeddedFontList():Object {
    return null;
  }

  public function get focusPane():Sprite {
    return null;
  }

  public function set focusPane(value:Sprite):void {
  }

  public function get isProxy():Boolean {
    return false;
  }

  private var _numModalWindows:int = 0;
  public function get numModalWindows():int {
    return _numModalWindows;
  }

  public function set numModalWindows(value:int):void {
    _numModalWindows = value;
  }

  public function get rawChildren():IChildList {
    return null;
  }

  private var _screen:Rectangle;
  public function get screen():Rectangle {
    if (_screen == null) {
      _screen = new Rectangle();
    }

    _screen.width = super.parent.width;
    _screen.height = super.parent.height;
    return _screen;
  }

  public function get topLevelSystemManager():ISystemManager {
    return this;
  }

  public function getDefinitionByName(name:String):Object {
    return ApplicationDomain.currentDomain.getDefinition(name);
  }

  public function isTopLevel():Boolean {
    return true;
  }

  public function isFontFaceEmbedded(tf:TextFormat):Boolean {
    return false;
  }

  public function isTopLevelRoot():Boolean {
    return true;
  }

  public function getTopLevelRoot():DisplayObject {
    return this;
  }

  public function getSandboxRoot():DisplayObject {
    return stage;
  }

  public function getVisibleApplicationRect(bounds:Rectangle = null, skipToSandboxRoot:Boolean = false):Rectangle {
    throw new Error("unsupportedProperty");
  }

  public function deployMouseShields(deploy:Boolean):void {
  }

  public function invalidateParentSizeAndDisplayList():void {
  }

  public function allowInsecureDomain(... rest):void {
  }

  public function get document():Object {
    return contentView;
  }

  public function set document(value:Object):void {
  }

  public function get allowDomainsInNewRSLs():Boolean {
    return false;
  }

  public function set allowDomainsInNewRSLs(value:Boolean):void {
  }

  public function get allowInsecureDomainsInNewRSLs():Boolean {
    return false;
  }

  public function set allowInsecureDomainsInNewRSLs(value:Boolean):void {
  }

  public function addPreloadedRSL(loaderInfo:LoaderInfo, rsl:Vector.<RSLData>):void {
  }
}
}

import cocoa.WindowedSystemManager;

import flash.display.DisplayObject;
import flash.geom.Point;

import mx.core.IChildList;

class SystemChildList implements IChildList {
  public function SystemChildList(owner:WindowedSystemManager, lowerBoundReference:String, upperBoundReference:String) {
    this.owner = owner;
    this.lowerBoundReference = lowerBoundReference;
    this.upperBoundReference = upperBoundReference;
  }

	private var owner:WindowedSystemManager;

	private var lowerBoundReference:String;
	private var upperBoundReference:String;

  public function get numChildren():int {
    return owner[upperBoundReference] - owner[lowerBoundReference];
  }

  public function addChild(child:DisplayObject):DisplayObject {
    return owner.addRawChildAt(child, owner[upperBoundReference]++);
  }

  public function addChildAt(child:DisplayObject, index:int):DisplayObject {
    owner.addRawChildAt(child, owner[lowerBoundReference] + index);
    owner[upperBoundReference]++;
    return child;
  }

  public function removeChild(child:DisplayObject):DisplayObject {
    var index:int = owner.getChildIndex(child);
    if (owner[lowerBoundReference] <= index && index < owner[upperBoundReference]) {
      owner.removeRawChild(child);
      owner[upperBoundReference]--;
    }
    return child;
  }

  public function removeChildAt(index:int):DisplayObject {
    var child:DisplayObject = owner.removeRawChildAt(index + owner[lowerBoundReference]);
    owner[upperBoundReference]--;
    return child;
  }

  public function getChildAt(index:int):DisplayObject {
    return owner.getRawChildAt(owner[lowerBoundReference] + index);
  }

  public function getChildByName(name:String):DisplayObject {
    return owner.getChildByName(name);
  }

  public function getChildIndex(child:DisplayObject):int {
    return owner.getChildIndex(child) - owner[lowerBoundReference] + WindowedSystemManager.OFFSET;
  }

  public function setChildIndex(child:DisplayObject, newIndex:int):void {
    owner.setChildIndex(child, owner[lowerBoundReference] + newIndex - WindowedSystemManager.OFFSET);
  }

  public function getObjectsUnderPoint(point:Point):Array {
    return owner.$getObjectsUnderPoint(point);
  }

  public function contains(child:DisplayObject):Boolean {
    if (child != owner && owner.$contains(child)) {
      while (child.parent != owner) {
        child = child.parent;
      }
      var childIndex:int = owner.getChildIndex(child) + WindowedSystemManager.OFFSET;
      if (childIndex >= owner[lowerBoundReference] && childIndex < owner[upperBoundReference]) {
        return true;
      }
    }
    return false;
  }
}
