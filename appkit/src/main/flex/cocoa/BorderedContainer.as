package cocoa {
import flash.display.Graphics;

import spark.components.ResizeMode;

public class BorderedContainer extends Container {
  private var _border:Border;
  public function get border():Border {
    return _border;
  }

  public function set border(value:Border):void {
    _border = value;
  }

  // GroupBase не вызывает drawBackground, поэтому мы не переопределяем drawBackground как в BorderedDataGroup
  override protected function updateDisplayList(w:Number, h:Number):void {
    if (_border != null) {
      var g:Graphics = graphics;
      g.clear();
      _border.draw(g, resizeMode == ResizeMode.SCALE ? measuredWidth : w, resizeMode == ResizeMode.SCALE ? measuredHeight : h, horizontalScrollPosition, verticalScrollPosition, this);
    }

    super.updateDisplayList(w, h);
  }
}
}