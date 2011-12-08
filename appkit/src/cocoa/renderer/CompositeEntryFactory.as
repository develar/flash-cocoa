package cocoa.renderer {
import cocoa.SkinnableView;

import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.text.engine.TextLine;

public class CompositeEntryFactory extends TextLineAndDisplayObjectEntryFactory {
  private var additionalSize:int;

  public function CompositeEntryFactory(additionalSize:int) {
    super(Shape, true);
    this.additionalSize = additionalSize;
  }

  override public function create(line:TextLine):TextLineAndDisplayObjectEntry {
    if (poolSize == 0) {
      return new CompositeEntry(additionalSize, line, new Shape(), this);
    }
    else {
      var entry:TextLineAndDisplayObjectEntry = pool[--poolSize];
      entry.line = line;
      return entry;
    }
  }

  override public function finalizeReused(container:DisplayObjectContainer):void {
    for (var i:int = oldPoolSize, n:int = poolSize; i < n; i++) {
      var e:CompositeEntry = CompositeEntry(pool[i]);
      e.displayObject.parent.removeChild(e.displayObject);
      for each (var component:SkinnableView in e.components) {
        component.removeFromSuperview();
      }
    }
    oldPoolSize = poolSize;
  }
}
}
