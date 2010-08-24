package cocoa.plaf.basic {
import cocoa.plaf.Skin;

import flash.geom.Point;

public class PullDownMenuController extends PopUpMenuController {
  override protected function setPopUpPosition():void {
    var popUpButtonSkin:Skin = popUpButton.skin;
    sharedPoint.x = 0;
    sharedPoint.y = 22;
    var globalPosition:Point = popUpButtonSkin.localToGlobal(sharedPoint);
    MenuSkin(menu.skin).move(globalPosition.x, globalPosition.y);
  }
}
}