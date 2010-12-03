package cocoa {
import flash.display.NativeWindow;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;

import mx.core.IWindow;

public class MainWindowedApplication extends ApplicationImpl implements IWindow {
  public function MainWindowedApplication() {
  }

  [Bindable("hide")]
  [Bindable("show")]
  [Bindable("windowComplete")]

  override public function get visible():Boolean {
    return false;
  }

  public function get maximizable():Boolean {
    return false;
  }

  public function get minimizable():Boolean {
    return false;
  }

  public function get nativeWindow():NativeWindow {
    if (systemManager != null && systemManager.stage != null) {
      return systemManager.stage.nativeWindow;
    }

    return null;
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
    return NativeWindowSystemChrome.STANDARD;
  }

  public function get title():String {
    return null;
  }

  public function set title(value:String):void {

  }

  public function get titleIcon():Class {
    return null;
  }

  public function set titleIcon(value:Class):void {

  }

  public function get type():String {
    // The initial window is always of type "normal".
    return NativeWindowType.NORMAL;
  }

  public function get transparent():Boolean {
    return false;
  }

  public function close():void {

  }

  public function maximize():void {

  }

  public function minimize():void {

  }

  public function restore():void {
    
  }
}
}
