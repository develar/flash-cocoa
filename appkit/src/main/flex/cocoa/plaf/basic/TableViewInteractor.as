package cocoa.plaf.basic {
import cocoa.plaf.TableViewSkin;
import cocoa.tableView.TableView;

import flash.display.InteractiveObject;

import flash.display.Sprite;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.system.Capabilities;
import flash.ui.Keyboard;

public class TableViewInteractor {
  protected var openedEditor:InteractiveObject;

  public function register(tableView:TableView):void {
    var bodyHitArea:Sprite = TableViewSkin(tableView.skin).bodyHitArea;
    bodyHitArea.mouseChildren = false;
    bodyHitArea.doubleClickEnabled = true;

    bodyHitArea.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
  }

  protected function keyDownHandler(event:KeyboardEvent):void {
    const isMac:Boolean = Capabilities.os.indexOf("Mac OS") != -1;

    switch (event.keyCode) {
      case Keyboard.ESCAPE:
        closeEditor(false);
        break;

      case Keyboard.ENTER:
        if (isMac) {
          openedEditor == null ? openEditor() : closeEditor(true);
        }
        else if (openedEditor != null) {
          closeEditor(true);
        }
        break;

      case Keyboard.F2:
        if (!isMac && openedEditor == null) {
          openEditor();
        }
        break;
    }
  }

  protected function closeEditor(commit:Boolean):void {

  }

  protected function openEditor():void {

  }

  protected function registerEditor():void {
    openedEditor.addEventListener(FocusEvent.FOCUS_OUT, editorFocusOutHandler);
  }

  private function editorFocusOutHandler(event:FocusEvent):void {
    InteractiveObject(event.currentTarget).removeEventListener(FocusEvent.FOCUS_OUT, editorFocusOutHandler);
    closeEditor(true);
  }
}
}
