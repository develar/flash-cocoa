package cocoa.border {
import cocoa.Border;
import cocoa.Insets;
import cocoa.View;

import flash.display.Graphics;

public class StatefulBorderImpl extends AbstractBorder implements StatefulBorder {
  private var borders:Vector.<Border>;

  public function StatefulBorderImpl(borders:Vector.<Border>, contentInsets:Insets = null) {
    if (contentInsets != null) {
      _contentInsets = contentInsets;
    }
    
    this.borders = borders;
  }

  protected var _borderIndex:int;
  public function set stateIndex(value:int):void {
    _borderIndex = value;
  }

  public function hasState(stateIndex:int):Boolean {
    return stateIndex < borders.length;
  }

  override public function draw(g:Graphics, w:Number, h:Number, x:Number = 0, y:Number = 0, view:View = null):void {
    borders[_borderIndex].draw(g, w, h, x, y, view);
  }
}
}