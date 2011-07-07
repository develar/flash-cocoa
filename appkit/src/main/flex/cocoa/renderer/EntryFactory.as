package cocoa.renderer {
import flash.display.DisplayObjectContainer;

public interface EntryFactory {
  function finalizeReused(container:DisplayObjectContainer):void;
  function preReuse():void
}
}
