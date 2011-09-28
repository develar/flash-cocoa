package cocoa.plaf.basic {
import cocoa.plaf.TableViewSkin;
import cocoa.tableView.TableView;

import flash.display.Sprite;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;
import flash.system.Capabilities;
import flash.ui.Keyboard;

public class TableViewInteractor {
  protected var openedEditorInfo:OpenedEditorInfo;

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
        if (openedEditorInfo != null) {
          closeEditor(false);
        }
        break;

      case Keyboard.ENTER:
        if (isMac) {
          openedEditorInfo == null ? openEditor() : closeEditor(true);
        }
        else if (openedEditorInfo != null) {
          closeEditor(true);
        }
        break;

      case Keyboard.F2:
        if (!isMac && openedEditorInfo == null) {
          openEditor();
        }
        break;
    }
  }

  protected function closeEditor(commit:Boolean):void {
    openedEditorInfo.editor.removeEventListener(FocusEvent.FOCUS_OUT, editorFocusOutHandler);

    try {
      if (commit) {
        closeAndCommit();
      }
      else {
        closeAndRollback();
      }
    }
    finally {
      openedEditorInfo = null;
    }
  }

  protected function closeAndRollback():void {
  }

  protected function closeAndCommit():void {
  }

  protected function openEditor():void {
  }

  protected function registerEditor():void {
    openedEditorInfo.editor.addEventListener(FocusEvent.FOCUS_OUT, editorFocusOutHandler);
  }

  private function editorFocusOutHandler(event:FocusEvent):void {
    closeEditor(true);
  }
}
}
