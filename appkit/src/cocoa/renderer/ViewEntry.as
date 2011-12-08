package cocoa.renderer {
import cocoa.View;

import flash.display.Shape;
import flash.text.engine.TextLine;

public class ViewEntry extends TextLineAndDisplayObjectEntry {
  public var view:View;

  public function ViewEntry(line:TextLine, shape:Shape, factory:ViewEntryFactory) {
    super(line, shape, factory);
  }

  override public function moveX(increment:Number):void {
    super.moveX(increment);

    view.setLocation(view.x + increment, view.y);
  }

  override public function moveY(increment:Number):void {
    super.moveY(increment);

    view.setLocation(view.x, view.y + increment);
  }
}
}