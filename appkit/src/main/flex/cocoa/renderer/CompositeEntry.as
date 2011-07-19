package cocoa.renderer {
import cocoa.Component;

import flash.display.Shape;
import flash.text.engine.TextLine;

public class CompositeEntry extends TextLineAndDisplayObjectEntry {
  public var components:Vector.<Component>;

  public function CompositeEntry(additionalSize:int, line:TextLine, shape:Shape, factory:CompositeEntryFactory) {
    super(line, shape, factory);

    components = new Vector.<Component>(additionalSize, true);
  }
}
}
