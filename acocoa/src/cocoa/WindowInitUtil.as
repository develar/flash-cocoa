package cocoa {
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;

internal final class WindowInitUtil {
  public static function initStage(stage:Stage):void {
    stage.scaleMode = StageScaleMode.NO_SCALE;
    stage.align = StageAlign.TOP_LEFT;
  }
}
}
