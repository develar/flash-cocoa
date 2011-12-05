package cocoa.dialog {
import cocoa.PushButton;
import cocoa.ViewContainer;
import cocoa.Window;
import cocoa.dialog.events.DialogEvent;
import cocoa.keyboard.KeyCode;
import cocoa.resources.ResourceManager;
import cocoa.ui;

import flash.events.KeyboardEvent;
import flash.ui.Keyboard;
import flash.utils.Dictionary;

use namespace ui;

[Event(name="ok", type="cocoa.dialog.events.DialogEvent")]
[Event(name="cancel", type="cocoa.dialog.events.DialogEvent")]

[ResourceBundle("Dialog")]
public class Dialog extends Window {
  private static const RESOURCE_BUNDLE:String = "Dialog";

  private var controlBarInitialized:Boolean;

  private static const _skinParts:Dictionary = new Dictionary();
  _skinParts.controlBar = HANDLER_NOT_EXISTS;
  override protected function get skinParts():Dictionary {
    return _skinParts;
  }

  public function Dialog() {
    super();

    flags &= ~CLOSABLE;
  }

  ui var controlBar:ViewContainer;

  private var okButton:PushButton;
  private var cancelButton:PushButton;

  protected var controlButtons:Vector.<PushButton>;

  override protected function get primaryLaFKey():String {
    return RESOURCE_BUNDLE;
  }

  private var _valid:Boolean;
  public function set valid(value:Boolean):void {
    if (value != _valid) {
      _valid = value;
      if (okButton != null) {
        //okButton.enabled = _valid;
      }
    }
  }

  private var _cancelVisible:Boolean = true;
  public function set cancelVisible(value:Boolean):void {
    if (value != _cancelVisible) {
      _cancelVisible = value;
      invalidateProperties();
    }
  }

  private var _okLabel:String = "okLabel";
  public function set okLabel(value:String):void {
    if (value != _okLabel) {
      _okLabel = value;
      invalidateProperties();
    }
  }

  override public function commitProperties():void {
    if (!controlBarInitialized) {
      controlBarInitialized = true;

      skin.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);

      if (_cancelVisible) {
        cancelButton = createControlButton(resourceManager.getString(RESOURCE_BUNDLE, "cancel"), cancel);
        controlBar.addSubview(cancelButton);
      }

      okButton = createControlButton(getOkLocalizedLabel(), ok);
      okButton.enabled = _valid;
      controlBar.addSubview(okButton);

      if (controlButtons != null) {
        for each (var controlButton:PushButton in controlButtons) {
          controlBar.addSubview(controlButton);
        }
      }
    }

    super.commitProperties();
  }

  protected function cancel():void {
    dispatchEvent(new DialogEvent(DialogEvent.CANCEL));
    close();
  }

  protected function ok():void {
    dispatchEvent(new DialogEvent(DialogEvent.OK));
    close();
  }

  private function createControlButton(label:String, actionHandler:Function):PushButton {
    var button:PushButton = new PushButton();
    button.title = label;
    button.action = actionHandler;
    button.right = 0;
    return button;
  }

  override protected function resourcesChanged():void {
    super.resourcesChanged();

    if (okButton != null) {
      okButton.title = getOkLocalizedLabel();
    }
    if (cancelButton != null) {
      cancelButton.title = resourceManager.getString(RESOURCE_BUNDLE, "cancel");
    }
  }

  protected function getOkLocalizedLabel():String {
    return ResourceManager(resourceManager).getStringWithDefault(_resourceBundle, _okLabel, RESOURCE_BUNDLE, "ok");
  }

  private function keyDownHandler(event:KeyboardEvent):void {
    if (event.isDefaultPrevented()) {
      return;
    }

    // Safari перехватывает cmd + period
    if (event.keyCode == Keyboard.ESCAPE || (event.ctrlKey && event.keyCode == KeyCode.PERIOD)) {
      cancel();
    }
    else if (event.keyCode == Keyboard.ENTER && _valid) {
      ok();
    }
  }
}
}