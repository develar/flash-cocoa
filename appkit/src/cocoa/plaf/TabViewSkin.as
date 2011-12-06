package cocoa.plaf {
import cocoa.Insets;
import cocoa.View;

public interface TabViewSkin {
  function get contentInsets():Insets;

  function show(view:View):void;
  function hide():void;
}
}
