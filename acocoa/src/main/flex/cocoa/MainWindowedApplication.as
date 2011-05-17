package cocoa {
import cocoa.plaf.LookAndFeel;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.resources.ResourceManager;

import flash.display.DisplayObject;
import flash.display.LoaderInfo;
import flash.display.Sprite;
import flash.geom.Rectangle;
import flash.system.ApplicationDomain;
import flash.text.TextFormat;
import flash.utils.Dictionary;

import mx.core.IChildList;
import mx.core.RSLData;
import mx.core.Singleton;
import mx.core.UIComponentGlobals;
import mx.core.mx_internal;
import mx.managers.ILayoutManager;
import mx.managers.ISystemManager;
import mx.managers.LayoutManager;
import mx.managers.NativeDragManagerImpl;
import mx.managers.SystemManagerGlobals;

use namespace mx_internal;

public class MainWindowedApplication extends Sprite implements ISystemManager, LookAndFeelProvider {
  public function MainWindowedApplication() {
    init();
  }

  private var _laf:LookAndFeel;
  public function get laf():LookAndFeel {
    return _laf;
  }

  public function set laf(value:LookAndFeel):void {
    _laf = value;
  }

  private function init():void {
    Singleton.registerClass("mx.managers::ILayoutManager", LayoutManager);
    Singleton.registerClass("mx.resources::IResourceManager", ResourceManager);
    Singleton.registerClass("mx.managers::IDragManager", NativeDragManagerImpl);

    SystemManagerGlobals.topLevelSystemManagers[0] = this;
    UIComponentGlobals.layoutManager = ILayoutManager(Singleton.getInstance("mx.managers::ILayoutManager"));

    initializeMaps();
  }

  protected function initializeMaps():void {

  }

  public function get preloadedRSLs():Dictionary {
    return null;
  }

  public function allowDomain(... rest):void {
  }

  public function allowInsecureDomain(... rest):void {
  }

  public function callInContext(fn:Function, thisArg:Object, argArray:Array, returns:Boolean = true):* {
    return null;
  }

  public function create(... rest):Object {
    return null;
  }

  public function info():Object {
    return null;
  }

  private const implementations:Dictionary = new Dictionary();
  public function getImplementation(interfaceName:String):Object {
    return implementations[interfaceName];
  }

  public function registerImplementation(interfaceName:String, impl:Object):void {
    implementations[interfaceName] = impl;
  }

  public function get cursorChildren():IChildList {
    return null;
  }

  public function get document():Object {
    return null;
  }

  public function set document(value:Object):void {
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

  public function get numModalWindows():int {
    return 0;
  }

  public function set numModalWindows(value:int):void {
  }

  public function get popUpChildren():IChildList {
    return null;
  }

  public function get rawChildren():IChildList {
    return null;
  }

  public function get screen():Rectangle {
    return null;
  }

  public function get toolTipChildren():IChildList {
    return null;
  }

  public function get topLevelSystemManager():ISystemManager {
    return this;
  }

  public function getDefinitionByName(name:String):Object {
    return ApplicationDomain.currentDomain.getDefinition(name);
  }

  public function isTopLevel():Boolean {
    return false;
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
    return this;
  }

  public function getVisibleApplicationRect(bounds:Rectangle = null, skipToSandboxRoot:Boolean = false):Rectangle {
    return null;
  }

  public function deployMouseShields(deploy:Boolean):void {
  }

  public function invalidateParentSizeAndDisplayList():void {
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
