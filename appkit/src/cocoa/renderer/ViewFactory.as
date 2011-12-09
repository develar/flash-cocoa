package cocoa.renderer {
import cocoa.View;
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;

import mx.core.IFactory;

public interface ViewFactory extends IFactory {
  function create(laf:LookAndFeel, container:DisplayObjectContainer):View;
}
}
