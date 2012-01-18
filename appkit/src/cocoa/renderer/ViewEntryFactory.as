package cocoa.renderer {
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import flash.text.engine.TextLine;

public class ViewEntryFactory extends TextLineAndDisplayObjectEntryFactory {
  public function ViewEntryFactory(displayObjectClass:Class = null) {
    super(displayObjectClass || Shape, true);
  }

  override public function create(line:TextLine):TextLineAndDisplayObjectEntry {
    if (poolSize == 0) {
      return new ViewEntry(line, new Shape(), this);
    }
    else {
      var entry:TextLineAndDisplayObjectEntry = pool[--poolSize];
      entry.line = line;
      return entry;
    }
  }

  override public function finalizeReused(container:DisplayObjectContainer):void {
    for (var i:int = oldPoolSize, n:int = poolSize; i < n; i++) {
      var e:ViewEntry = ViewEntry(pool[i]);
      e.displayObject.parent.removeChild(e.displayObject);
      e.view.removeFromSuperview();
    }
    oldPoolSize = poolSize;
  }
}
}
