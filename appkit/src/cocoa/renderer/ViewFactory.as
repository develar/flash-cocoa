package cocoa.renderer {
import cocoa.ContentView;
import cocoa.View;
import cocoa.plaf.LookAndFeel;

import flash.display.DisplayObjectContainer;

import mx.core.IFactory;

public interface ViewFactory extends IFactory {
  function create(laf:LookAndFeel, container:DisplayObjectContainer, superview:ContentView):View;
}
}
