package cocoa.plaf.basic {
import cocoa.plaf.TableViewSkin;
import cocoa.tableView.TableView;

import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

public class TableViewInteractor {
  public function register(tableView:TableView):void {
    var bodyHitArea:Sprite = TableViewSkin(tableView.skin).bodyHitArea;
    bodyHitArea.mouseChildren = false;
    bodyHitArea.doubleClickEnabled = true;

    bodyHitArea.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
  }

  protected function keyDownHandler(event:KeyboardEvent):void {
    switch (event.keyCode) {
      case Keyboard.ESCAPE:
        closeEditor();
        break;

      case Keyboard.ENTER:
        openEditor();
        break;
    }
  }

  protected function closeEditor():void {

  }

  protected function openEditor():void {

  }
}
}
