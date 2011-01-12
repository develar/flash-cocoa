package cocoa.plaf.aqua {
import cocoa.Border;
import cocoa.Insets;
import cocoa.plaf.basic.AbstractTabViewSkin;

import flash.display.Graphics;

public class TabViewSkin extends AbstractTabViewSkin {
  private var border:Border;

  override public function get contentInsets():Insets {
    return border.contentInsets;
  }

  override protected function createChildren():void {
    border = getBorder();
    super.createChildren();
  }

  override protected function updateDisplayList(w:Number, h:Number):void {
    super.updateDisplayList(w, h);

    var g:Graphics = graphics;
    g.clear();
    border.draw(null, g, w, h);
  }
}
}