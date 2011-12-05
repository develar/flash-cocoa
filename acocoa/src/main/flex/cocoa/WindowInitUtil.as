package cocoa {
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;

import mx.core.mx_internal;
import mx.managers.ISystemManager;
import mx.managers.SystemManagerGlobals;

use namespace mx_internal;

internal final class WindowInitUtil {
  public static function initMainSystemManager(systemManager:ISystemManager):void {
    //Singleton.registerClass("mx.managers::ILayoutManager", LayoutManager);
    //Singleton.registerClass("mx.resources::IResourceManager", ResourceManager);

    SystemManagerGlobals.topLevelSystemManagers[0] = systemManager;
    //UIComponentGlobals.layoutManager = ILayoutManager(Singleton.getInstance("mx.managers::ILayoutManager"));
  }

  public static function initStage(stage:Stage):void {
    stage.scaleMode = StageScaleMode.NO_SCALE;
    stage.align = StageAlign.TOP_LEFT;
  }
}
}
