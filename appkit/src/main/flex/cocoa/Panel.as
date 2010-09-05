package cocoa {
import cocoa.sidebar.events.SidebarEvent;

import flash.utils.Dictionary;

import spark.components.supportClasses.TextBase;

use namespace ui;

public class Panel extends Window {
  protected static const _skinParts:Dictionary = new Dictionary();
  _skinParts.minimizeButton = 0;
  _skinParts.closeSideButton = 0;
  override protected function get skinParts():Dictionary {
    return _skinParts;
  }

  ui var titleDisplay:TextBase;

  ui var minimizeButton:PushButton;
  ui var closeSideButton:PushButton;

  ui function minimizeButtonAdded():void {
    minimizeButton.action = minimizeButtonActionHandler;
  }

  ui function closeSideButtonAdded():void {
    closeSideButton.action = closeSideButtonClickHandler;
  }

  private function minimizeButtonActionHandler():void {
    dispatchEvent(new SidebarEvent(SidebarEvent.HIDE_PANE));
  }

  private function closeSideButtonClickHandler():void {
    dispatchEvent(new SidebarEvent(SidebarEvent.HIDE_SIDE));
  }

  override protected function get primaryLaFKey():String {
    return "Panel";
  }
}
}