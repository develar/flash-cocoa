package cocoa.plaf {
import cocoa.Insets;
import cocoa.View;

public interface TabViewSkin {
  function get contentInsets():Insets;

  function show(viewable:View):void;
  function hide():void;
}
}
