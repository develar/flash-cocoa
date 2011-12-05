package cocoa.plaf.basic {
import cocoa.plaf.Skin;
import cocoa.util.SharedPoint;

import flash.geom.Point;

public class PullDownMenuInteractor extends PopUpMenuInteractor {
  override protected function setPopUpPosition():void {
    var popUpButtonSkin:Skin = popUpButton.skin;
    var point:Point = SharedPoint.point;
    point.x = 0;
    point.y = 22;
    point = popUpButtonSkin.localToGlobal(point);
    MenuSkin(menu.skin).move(point.x, point.y);
  }
}
}