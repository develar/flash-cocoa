package cocoa {
import flash.utils.Dictionary;

import org.osflash.signals.ISignal;
import org.osflash.signals.Signal;

use namespace ui;

public class Panel extends Window {
  protected static const _skinParts:Dictionary = new Dictionary();
  _skinParts.minimizeButton = 0;
  _skinParts.closeSideButton = 0;
  override protected function get skinParts():Dictionary {
    return _skinParts;
  }

  ui var minimizeButton:PushButton;
  ui var closeSideButton:PushButton;

  ui function minimizeButtonAdded():void {
    minimizeButton.action = minimizeButtonActionHandler;
  }

  ui function closeSideButtonAdded():void {
    closeSideButton.action = closeSideButtonClickHandler;
  }

  private var _emptyText:String;
  public function get emptyText():String {
    return _emptyText;
  }
  public function set emptyText(value:String):void {
    _emptyText = value;
    if (skin != null) {
      skin.invalidateDisplayList();
    }
  }

  private var _paneHid:ISignal = new Signal(Panel);
  public function get paneHid():ISignal {
    return _paneHid;
  }

  private var _sideHid:ISignal = new Signal();
  public function get sideHid():ISignal {
    return _sideHid;
  }

  private function minimizeButtonActionHandler():void {
    _paneHid.dispatch(this);
  }

  private function closeSideButtonClickHandler():void {
    _sideHid.dispatch();
  }

  override protected function get primaryLaFKey():String {
    return "Panel";
  }
}
}