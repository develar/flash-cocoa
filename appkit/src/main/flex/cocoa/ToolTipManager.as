package cocoa {
import flash.display.DisplayObject;
import flash.geom.Point;

import mx.core.mx_internal;
import mx.managers.ISystemManager;
import mx.managers.ToolTipManagerImpl;

use namespace mx_internal;

/**
 * пришлось переопределять стандарный для решение проблемы неправильного позиционирования — над иконкой в нижнем правом углу он располагается под курсором мыши,
 * в результате чего начинает мерцать (так как раз он под мышей, он тут же пропадает, а потом тут же появляется) — он должен позиционировать при нехватке места над bounds мыши/края контрола
 */
public class ToolTipManager extends ToolTipManagerImpl {
  private static const sharedPoint:Point = new Point();

  private static var _instance:ToolTipManager;
  public static function get instance():ToolTipManager {
    if (_instance == null) {
      _instance = new ToolTipManager();
    }

    return _instance;
  }

  [Deprecated]
  public static function getInstance():ToolTipManager {
    return instance;
  }

  mx_internal override function positionTip():void {
    var sm:ISystemManager = getSystemManager(currentTarget);
    // Position the upper-left (upper-right) of the tooltip at the lower-right (lower-left) of the arrow cursor.
    var x:Number = DisplayObject(sm).mouseX + 11;
    // If the tooltip is too wide to fit onstage, move it left (right).
    var widthAdjustment:Number = currentToolTip.screen.width - x - currentToolTip.width;
    if (widthAdjustment < 0) {
      x += widthAdjustment;
    }

    var y:Number = DisplayObject(sm).mouseY + 22;
    // If the tooltip is too tall to fit onstage, move it up.
    var heightAdjustment:Number = currentToolTip.screen.height - y - currentToolTip.height;
    if (heightAdjustment < 0) {
      y += heightAdjustment - 22;
    }

    sharedPoint.x = x;
    sharedPoint.y = y;
    var position:Point = DisplayObject(sm.getSandboxRoot()).globalToLocal(DisplayObject(sm).localToGlobal(sharedPoint));
    x = position.x;
    y = position.y;

    currentToolTip.move(x, y);
  }
}
}