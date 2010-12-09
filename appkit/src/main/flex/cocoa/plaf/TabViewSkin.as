package cocoa.plaf {
import cocoa.Insets;
import cocoa.Viewable;

public interface TabViewSkin {
  function get contentInsets():Insets;

  function show(viewable:Viewable):void;
}
}
