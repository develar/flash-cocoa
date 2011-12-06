package cocoa.plaf.aqua {
import cocoa.SkinnableView;
import cocoa.Insets;
import cocoa.View;
import cocoa.plaf.LookAndFeelProvider;

import flash.display.Graphics;

public class HUDWindowSkin extends AbstractWindowSkin {
  private static const TITLE_BAR_HEIGHT:Number = 19;

  private static const CONTENT_FRAME_INSETS:Insets = new Insets(0, TITLE_BAR_HEIGHT + 1, 0, 0);
  private static const CONTENT_LAYOUT_INSETS:Insets = new Insets(10, 10, 10, 10);

  override protected function get contentFrameInsets():Insets {
    return CONTENT_FRAME_INSETS;
  }

  override public function attach(component:SkinnableView):void {
    super.attach(component);
  }

  override protected function drawTitleBottomBorderLine(g:Graphics, w:Number):void {
    // skip
  }

  override protected function get contentLayoutInsets():Insets {
    return CONTENT_LAYOUT_INSETS;
  }

  override protected function get titleBarHeight():Number {
    return TITLE_BAR_HEIGHT;
  }

  override protected function get titleY():Number {
    return 14;
  }

  override public function set contentView(value:View):void {
    super.contentView = value;
    if (value is LookAndFeelProvider) {
      LookAndFeelProvider(value).laf = laf;
    }
    value.mouseEnabled = false; // контейнеру не нужно быть mouseEnabled — это помешает перемещать окно (HUD окно таскается не только за хром, но и за все, где не перекрывается content view controls)
  }

  override protected function get mouseDownOnContentViewCanMoveWindow():Boolean {
    return true;
  }

  override protected function createChildren():void {
    super.createChildren();
  }
}
}