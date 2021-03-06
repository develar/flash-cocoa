package cocoa.dialog {
import cocoa.ComponentEvent;
import cocoa.DeferredSkinOwner;
import cocoa.Window;
import cocoa.dialog.events.DialogEvent;
import cocoa.plaf.LookAndFeelProvider;
import cocoa.plaf.Skin;

import flash.display.DisplayObject;
import flash.events.Event;

import mx.managers.PopUpManager;
import mx.managers.SystemManagerGlobals;

import org.flyti.plexus.PlexusManager;
import org.flyti.plexus.events.InjectorEvent;

public class DialogManager {
  private var modalWindowSkin:Skin;

  public static function get instance():DialogManager {
    return DialogManager(PlexusManager.instance.container.lookup(DialogManager));
  }

  public function open(window:Window, modal:Boolean = true, autoCenter:Boolean = true):void {
    if (modal) {
      if (modalWindowSkin != null) {
        throw new Error("modal window already opened");
      }
    }

    window.addEventListener(Event.CLOSE, closeHandler);

    if (window is DeferredSkinOwner && !DeferredSkinOwner(window).isReadyToCreateSkin) {
      window.addEventListener(ComponentEvent.READY_TO_CREATE_SKIN, readyToCreateSkinHandler);
    }
    else {
      addPopUp(window, modal, true, autoCenter);
    }
  }

  private function readyToCreateSkinHandler(event:ComponentEvent):void {
    addPopUp(Window(event.currentTarget), true, false);
  }

  private function addPopUp(window:Window, modal:Boolean = true, dispatchInjectorEvent:Boolean = true, autoCenter:Boolean = true):void {
    var skin:Skin = window.skin;
    if (skin == null) {
      window.laf = LookAndFeelProvider(SystemManagerGlobals.topLevelSystemManagers[0]).laf;
      skin = window.createView(window.laf);
      if (dispatchInjectorEvent) {
        skin.dispatchEvent(new InjectorEvent(window));
      }
    }

    var popUpLayerParent:DisplayObject = DisplayObject(SystemManagerGlobals.topLevelSystemManagers[0]);
    if (modal && popUpLayerParent.stage != null /* only for testToolApp, temp hack */) {
      modalWindowSkin = skin;
      popUpLayerParent.stage.addEventListener(Event.RESIZE, stageResizeHandler);
    }

    PopUpManager.addPopUp(skin, popUpLayerParent, modal);
    if (autoCenter) {
      PopUpManager.centerPopUp(skin);
    }
    //!! skin.setFocus();
  }

  private function stageResizeHandler(event:Event):void {
    PopUpManager.centerPopUp(modalWindowSkin);
  }

  public function close(window:Window):void {
    window.removeEventListener(Event.CLOSE, closeHandler);

    window.dispatchEvent(new DialogEvent(DialogEvent.CLOSING));

    if (modalWindowSkin != null) {
      modalWindowSkin.stage.removeEventListener(Event.RESIZE, stageResizeHandler);
      modalWindowSkin = null;
    }
    PopUpManager.removePopUp(window.skin);
  }

  private function closeHandler(event:Event):void {
    close(Window(event.currentTarget));
  }
}
}