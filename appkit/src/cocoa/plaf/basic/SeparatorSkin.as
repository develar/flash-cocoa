package cocoa.plaf.basic {
import cocoa.Border;

import flash.display.Graphics;

public class SeparatorSkin extends AbstractSkin {
  private var border:Border;

  public function SeparatorSkin() {
    super();

    mouseEnabled = false;
    mouseChildren = false;
  }

  override protected function doInit():void {
    super.doInit();

    border = laf.getBorder(component.lafKey + ".b", false);
    if (border.layoutWidth < 0) {
      //percentWidth = -border.layoutWidth;
    }
  }

  //override protected function measure():void {
  //  measuredWidth = isNaN(border.layoutWidth) ? 0 : border.layoutWidth;
  //  measuredHeight = isNaN(border.layoutHeight) ? 0 : border.layoutHeight;
  //}

  override protected function draw(w:int, h:int):void {
    var g:Graphics = graphics;
    g.clear();
    border.draw(g, w, h);
  }
}
}